# go template

![check](https://gitea.com/spotdemo4/go-template/actions/workflows/check.yaml/badge.svg)
![vulnerable](https://gitea.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml/badge.svg)

Template for starting svelte projects, part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Getting started

```sh
# create direnv config
ln -s .envrc.project .envrc

# allow direnv to create dev environment
direnv allow

# install deps
npm i
```

## Running

```sh
npm run dev
```

## Building

```sh
# build using nix
nix build

# build using npm
npm run build
```

## Checking

```sh
# run all checks
nix flake check

# run npm checks
npm run check
```

## Releasing

```sh
# do nothing, releases are automatically created for significant changes

# manually create a new release
bumper
```
