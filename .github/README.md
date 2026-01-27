# sveltekit template

[![check](https://github.com/spotdemo4/svelte-template/actions/workflows/check.yaml/badge.svg?branch=main)](https://github.com/spotdemo4/svelte-template/actions/workflows/check.yaml)
[![vulnerable](https://github.com/spotdemo4/svelte-template/actions/workflows/vulnerable.yaml/badge.svg?branch=main)](https://github.com/spotdemo4/svelte-template/actions/workflows/vulnerable.yaml)

Template for starting [sveltekit](https://svelte.dev/) projects, part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Requirements

- [nix](https://nixos.org/)
- (optional) [direnv](https://direnv.net/)

## Getting started

Initialize direnv:

```elm
ln -s .envrc.project .envrc &&
direnv allow
```

or manually enter the development environment:

```elm
nix develop
```

then install dependencies:

```elm
npm i &&
npx svelte-kit sync
```

## Run

```elm
nix run #dev
```

## Build

```elm
nix build
```

## Check

```elm
nix flake check
```

## Release

Releases are automatically created for significant changes.

To manually create a new release:

```elm
bumper
```

## Use

### Binary

| OS      | Architecture | Download                                                                                                                                                         |
| ------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Linux   | amd64        | [svelte-template-0.5.3-x86_64-linux.tar.xz](https://github.com/spotdemo4/svelte-template/releases/download/v0.5.3/svelte-template-0.5.3-x86_64-linux.tar.xz)     |
| Linux   | arm64        | [svelte-template-0.5.3-aarch64-linux.tar.xz](https://github.com/spotdemo4/svelte-template/releases/download/v0.5.3/svelte-template-0.5.3-aarch64-linux.tar.xz)   |
| MacOS   | arm64        | [svelte-template-0.5.3-aarch64-darwin.tar.xz](https://github.com/spotdemo4/svelte-template/releases/download/v0.5.3/svelte-template-0.5.3-aarch64-darwin.tar.xz) |
| Windows | amd64        | [svelte-template-0.5.3-x86_64-windows.zip](https://github.com/spotdemo4/svelte-template/releases/download/v0.5.3/svelte-template-0.5.3-x86_64-windows.zip)       |

### Docker

```elm
docker run ghcr.io/spotdemo4/svelte-template:0.5.3
```

### Nix

```elm
nix run github:spotdemo4/svelte-template
```
