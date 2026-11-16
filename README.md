# Fluid-commerce Fluid

**The Fluid CLI is no longer installed with Homebrew.** Install it from npm,
with the Sites plugin:

```sh
npm install -g @fluid-app/fluid-cli @fluid-app/fluid-cli-member-site
```

If you installed `fluid_cli` from this tap, remove it first with
`brew uninstall fluid_cli`. The formula is disabled, so Homebrew refuses to
install it and points to npm.

## How do I install these formulae?

`brew install fluid-commerce/fluid/<formula>`

Or `brew tap fluid-commerce/fluid` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "fluid-commerce/fluid"
brew "<formula>"
```

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
