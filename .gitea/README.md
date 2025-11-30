# go template

![check](https://gitea.com/spotdemo4/svelte-template/actions/workflows/check.yaml/badge.svg)
![vulnerable](https://gitea.com/spotdemo4/svelte-template/actions/workflows/vulnerable.yaml/badge.svg)

Template for starting [SvelteKit](https://svelte.dev/) projects, part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Requirements

- [Nix](https://nixos.org/) package manager
- (optional) [direnv](https://direnv.net/)

## Getting started

Initialize direnv:

```elm
ln -s .envrc.project .envrc &&
direnv allow
```

or enter dev shell manually:

```elm
nix develop
```

then install dependencies:

```elm
npm i &&
npx svelte-kit sync
```

## Running

```elm
nix run
```

## Building

```elm
nix build
```

## Checking

```elm
nix flake check
```

## Releasing

Releases are automatically created for significant changes.

To manually create a new release:

```elm
bumper
```
