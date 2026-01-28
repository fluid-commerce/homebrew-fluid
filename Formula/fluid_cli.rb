# typed: strict
# frozen_string_literal: true

# formula generated from gem 'fluid_cli'
class FluidCli < Formula
  # Module to get Ruby binary path from Homebrew Ruby formula
  module RubyBin
    def ruby_bin
      Formula["ruby"].opt_bin
    end
  end

  # Custom download strategy to fetch gem from RubyGems
  class RubyGemsDownloadStrategy < AbstractDownloadStrategy
    include RubyBin

    def fetch(_timeout: nil, **_options)
      ohai("Fetching fluid-cli from gem source")
      cache.cd do
        ENV["GEM_SPEC_CACHE"] = "#{cache}/gem_spec_cache"

        _, err, status = Open3.capture3("gem", "fetch", "fluid_cli", "--version", gem_version)
        odie err unless status.success?
      end
    end

    def cached_location
      Pathname.new("#{cache}/fluid_cli-#{gem_version}.gem")
    end

    def cache
      @cache ||= HOMEBREW_CACHE
    end

    def gem_version
      @version ||= @resource&.version if defined?(@resource)
      raise "Unable to determine version; did Homebrew change?" unless @version

      @version
    end

    def clear_cache
      cached_location.unlink if cached_location.exist?
    end
  end

  include RubyBin

  desc "Fluid CLI tool"
  homepage "https://fluid.app"
  url "fluid_cli", using: RubyGemsDownloadStrategy
  version "0.1.8"
  sha256 "d820f93e9d19154ecb9ab281a9e2af9c88ea2ee9ee67c6a77ba6f07039059253"
  depends_on "ruby"

  def install
    # set GEM_HOME and GEM_PATH to make sure we package all the dependent gems
    # together without accidently picking up other gems on the gem path since
    # they might not be there if, say, we change to a different rvm gemset
    ENV["GEM_HOME"] = prefix.to_s
    ENV["GEM_PATH"] = prefix.to_s

    # Use /usr/local/bin at the front of the path instead of Homebrew shims,
    # which mess with Ruby's own compiler config when building native extensions
    ENV["PATH"] = ENV["PATH"].sub(HOMEBREW_SHIMS_PATH.to_s, "/usr/local/bin") if defined?(HOMEBREW_SHIMS_PATH)

    system(
      "gem",
      "install",
      cached_download,
      "--no-document",
      "--no-wrapper",
      "--no-user-install",
      "--install-dir", prefix,
      "--bindir", bin,
      "--",
      "--skip-cli-build"
    )

    raise "gem install 'fluid_cli' failed with status #{$CHILD_STATUS.exitstatus}" unless $CHILD_STATUS.success?

    rm_r(bin) if bin.exist?
    bin.mkpath

    brew_gem_prefix = "#{prefix}/gems/fluid_cli-#{version}"

    ruby_libs = Dir.glob("#{prefix}/gems/*/lib")
    exe = "fluid"
    file = Pathname.new("#{brew_gem_prefix}/exe/#{exe}")
    (bin + file.basename.to_s).open("w") do |f|
      f << <<~RUBY
        #!#{ruby_bin}/ruby -rjson --disable-gems
        ENV['ORIGINAL_ENV']=ENV.to_h.to_json
        ENV['GEM_HOME']="#{prefix}"
        ENV['GEM_PATH']="#{prefix}"
        ENV['RUBY_BINDIR']="#{ruby_bin}/"
        require 'rubygems'
        $:.unshift(#{ruby_libs.map(&:inspect).join(",")})
        load "#{file}"
      RUBY
    end
  end
end
