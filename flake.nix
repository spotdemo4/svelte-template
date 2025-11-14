{
  description = "template";

  nixConfig = {
    extra-substituters = [
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
    ];
  };

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    trev = {
      url = "github:spotdemo4/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    semgrep-rules = {
      url = "github:semgrep/semgrep-rules";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      utils,
      trev,
      semgrep-rules,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            trev.overlays.packages
            trev.overlays.libs
          ];
        };
        node = pkgs.nodejs_24;
        node-slim = pkgs.nodejs-slim_24;
      in
      rec {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # svelte
              node

              # util
              bumper

              # nix
              nixfmt
            ];
            shellHook = pkgs.shellhook.ref;
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              renovate

              # npm i
              node
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              # svelte
              node

              # nix
              flake-checker

              # actions
              octoscan
            ];
          };
        };

        checks = pkgs.lib.mkChecks {
          svelte = {
            src = packages.default;
            deps = with pkgs; [
              opengrep
            ];
            script = ''
              npx prettier --check .
              npx eslint .
              npx svelte-kit sync && npx svelte-check
              opengrep scan --quiet --error --use-git-ignore --config="${semgrep-rules}/typescript"
              opengrep scan --quiet --error --use-git-ignore --config="${semgrep-rules}/javascript"
            '';
          };

          nix = {
            src = ./.;
            deps = with pkgs; [
              nixfmt
            ];
            script = ''
              nixfmt -c flake.nix
            '';
          };

          actions = {
            src = ./.;
            deps = with pkgs; [
              action-validator
              octoscan
              renovate
            ];
            script = ''
              # github
              action-validator .github/**/*.yaml
              octoscan scan .github
              renovate-config-validator .github/renovate.json

              # gitea
              action-validator .gitea/**/*.yaml
              octoscan scan .gitea
              renovate-config-validator .gitea/renovate.json
            '';
          };
        };

        packages.default = pkgs.buildNpmPackage (finalAttrs: {
          pname = "svelte-template";
          version = "0.1.2";
          src = builtins.path {
            name = "root";
            path = ./.;
          };
          nodejs = node;

          npmDeps = pkgs.importNpmLock {
            npmRoot = finalAttrs.src;
          };

          npmConfigHook = pkgs.importNpmLock.npmConfigHook;

          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];

          doCheck = false;

          installPhase = ''
            runHook preInstall

             mkdir -p $out/{bin,lib/node_modules/svelte-template}
             cp -r build node_modules package.json $out/lib/node_modules/svelte-template

             makeWrapper "${pkgs.lib.getExe node-slim}" "$out/bin/svelte-template" \
               --add-flags "$out/lib/node_modules/svelte-template/build/index.js"

             runHook postInstall
          '';

          meta = {
            description = "svelte template";
            mainProgram = "svelte-template";
            homepage = "https://github.com/spotdemo4/svelte-template";
            changelog = "https://github.com/spotdemo4/svelte-template/releases/tag/v${finalAttrs.version}";
            license = pkgs.lib.licenses.mit;
            platforms = pkgs.lib.platforms.all;
          };
        });

        formatter = pkgs.nixfmt;
      }
    );
}
