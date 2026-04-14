{
  description = "svelte template";

  nixConfig = {
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };

  inputs = {
    systems.url = "github:spotdemo4/systems";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trev = {
      url = "github:spotdemo4/nur";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      trev,
      ...
    }:
    trev.libs.mkFlake (
      system: pkgs: {
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              nodejs_24

              # format
              nixfmt

              # util
              bumper
              flake-release
              renovate
            ];
          };

          bump = pkgs.mkShell {
            packages = with pkgs; [
              bumper
            ];
          };

          release = pkgs.mkShell {
            packages = with pkgs; [
              flake-release
            ];
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              renovate
              nodejs_24 # npm i
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_24 # npm audit
              flake-checker # nix
              octoscan # actions
            ];
          };
        };

        checks = pkgs.mkChecks {
          svelte = {
            src = self.packages.${system}.default;
            script = ''
              npx prettier --check .
              npx eslint .
              npx svelte-kit sync && npx svelte-check
            '';
          };

          actions = {
            root = ./.github/workflows;
            packages = with pkgs; [
              action-validator
              octoscan
            ];
            forEach = ''
              action-validator "$file"
              octoscan scan "$file"
            '';
          };

          renovate = {
            root = ./.github;
            fileset = ./.github/renovate.json;
            packages = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            packages = with pkgs; [
              nixfmt
            ];
            forEach = ''
              nixfmt --check "$file"
            '';
          };
        };

        apps = pkgs.mkApps {
          dev = "npm run dev";
        };

        packages = with pkgs.lib; {
          default = pkgs.buildNpmPackage (finalAttrs: {
            pname = "svelte-template";
            version = "0.6.3";

            src = fileset.toSource {
              root = ./.;
              fileset = fileset.difference ./. (
                fileset.unions [
                  ./.github
                  ./.vscode
                  ./flake.nix
                  ./flake.lock
                ]
              );
            };

            nodejs = pkgs.nodejs_24;
            npmConfigHook = pkgs.importNpmLock.npmConfigHook;
            npmDeps = pkgs.importNpmLock {
              npmRoot = finalAttrs.src;
            };

            meta = {
              mainProgram = "svelte-template";
              description = "A template for building svelte apps with nix";
              license = licenses.mit;
              platforms = platforms.all;
              homepage = "https://github.com/spotdemo4/svelte-template";
              changelog = "https://github.com/spotdemo4/svelte-template/releases/tag/v${finalAttrs.version}";
            };
          });
        };

        images = {
          default = pkgs.mkImage self.packages.${system}.default {
            contents = with pkgs; [ dockerTools.caCertificates ];
          };
        };

        schemas = trev.schemas;
        formatter = pkgs.nixfmt-tree;
      }
    );
}
