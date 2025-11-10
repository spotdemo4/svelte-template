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
    systems.url = "systems";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nur = {
      url = "github:spotdemo4/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    semgrep-rules = {
      url = "github:semgrep/semgrep-rules";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    utils,
    nur,
    semgrep-rules,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur.overlays.packages
          nur.overlays.libs
        ];
      };
      node = pkgs.nodejs_24;
      node-slim = pkgs.nodejs-slim_24;
    in rec {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # svelte
            node

            # lint
            alejandra

            # util
            bumper
          ];
          shellHook = pkgs.shellhook.ref;
        };

        update = pkgs.mkShell {
          packages = with pkgs; [
            renovate
            node # npm i
          ];
        };

        vulnerable = pkgs.mkShell {
          packages = with pkgs; [
            # svelte
            node

            # nix
            flake-checker
          ];
        };
      };

      checks =
        pkgs.lib.mkChecks {
          scan = {
            src = ./.;
            deps = with pkgs; [
              opengrep
            ];
            script = ''
              opengrep scan --quiet --error --config="${semgrep-rules}/typescript"
              opengrep scan --quiet --error --config="${semgrep-rules}/javascript"
            '';
          };

          nix = {
            src = ./.;
            deps = with pkgs; [
              alejandra
            ];
            script = ''
              alejandra -c .
            '';
          };

          actions = {
            src = ./.;
            deps = with pkgs; [
              action-validator
              renovate
            ];
            script = ''
              action-validator .github/**/*.yaml
              renovate-config-validator .github/renovate.json
            '';
          };
        }
        // {
          svelte = packages.default.overrideAttrs {
            doCheck = true;
            checkPhase = ''
              npx prettier --check .
              npx eslint .
              npx svelte-kit sync && npx svelte-check
            '';
          };
        };

      packages.default = pkgs.buildNpmPackage (finalAttrs: {
        pname = "svelte-template";
        version = "0.0.7";
        src = builtins.path {
          path = ./.;
          name = "root";
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

      formatter = pkgs.alejandra;
    });
}
