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
              nodejs_24 # npm publish
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

        apps = pkgs.mkApps {
          default = "npm run dev";
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
            filter = file: file.hasExt "yaml";
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
            files = ./.github/renovate.json;
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

        packages.default = pkgs.buildNpmPackage (
          final: with pkgs.lib; {
            pname = "svelte-template";
            version = "0.7.3";

            src = fileset.toSource {
              root = ./.;
              fileset = fileset.unions [
                ./.gitignore
                ./.npmrc
                ./eslint.config.ts
                ./package.json
                ./package-lock.json
                ./prettier.config.ts
                ./svelte.config.ts
                ./tsconfig.json
                ./vite.config.ts
                ./src
                ./static
              ];
            };

            nodejs = pkgs.nodejs_24;
            npmConfigHook = pkgs.importNpmLock.npmConfigHook;
            npmDeps = pkgs.importNpmLock {
              npmRoot = final.src;
            };

            meta = {
              mainProgram = "svelte-template";
              description = "A template for SvelteKit projects.";
              license = licenses.mit;
              platforms = platforms.all;
              badPlatforms = [ systems.inspect.platformPatterns.isStatic ];
              homepage = "https://github.com/spotdemo4/svelte-template";
              changelog = "https://github.com/spotdemo4/svelte-template/releases/tag/v${final.version}";
            };
          }
        );

        images.default = pkgs.mkImage {
          src = self.packages.${system}.default;
          contents = with pkgs; [ dockerTools.caCertificates ];
          config.ExposedPorts = {
            "3000/tcp" = { };
          };
        };

        appimages.default = pkgs.mkAppImage {
          src = self.packages.${system}.default;
        };

        formatter = pkgs.nixfmt-tree;
        schemas = trev.schemas;
      }
    );
}
