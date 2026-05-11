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
    trevpkgs = {
      url = "github:spotdemo4/trevpkgs";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      trevpkgs,
      ...
    }:
    trevpkgs.libs.mkFlake (
      system: pkgs: {

        # nix develop [#...]
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              # svelte
              nodejs_24

              # lint
              nixd
              nil

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
              nodejs_24 # npm install
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              flake-checker # nix
              zizmor # actions
              nodejs_24 # npm audit
            ];
          };
        };

        # nix run [#...]
        apps = pkgs.mkApps {
          dev = "npm run dev";
        };

        # nix build [#...]
        packages = {
          default = pkgs.buildNpmPackage (
            final: with pkgs.lib; {
              pname = "svelte-template";
              version = "0.8.0";

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

              checkPhase = ''
                npx prettier --check .
                npx eslint .
                npx svelte-kit sync && npx svelte-check
              '';

              meta = {
                mainProgram = "svelte-template";
                description = "A template for SvelteKit projects";
                license = licenses.mit;
                platforms = platforms.all;
                badPlatforms = [ systems.inspect.platformPatterns.isStatic ];
                homepage = "https://github.com/spotdemo4/svelte-template";
                changelog = "https://github.com/spotdemo4/svelte-template/releases/tag/v${final.version}";
              };
            }
          );
        };

        # nix build #images.[...]
        images = {
          default = pkgs.mkImage {
            src = self.packages.${system}.default;
            contents = with pkgs; [ dockerTools.caCertificates ];
            config.ExposedPorts = {
              "3000/tcp" = { };
            };
          };
        };

        # nix build #appimages.[...]
        appimages = {
          default = pkgs.mkAppImage {
            src = self.packages.${system}.default;
          };
        };

        # nix fmt
        formatter = pkgs.nixfmt-tree;

        # nix flake check
        checks = pkgs.mkChecks {
          svelte = self.packages.${system}.default.overrideAttrs {
            dontBuild = true;
            installPhase = ''
              touch $out
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            packages = with pkgs; [
              nixfmt
            ];
            script = ''
              nixfmt --check "$file"
            '';
          };

          actions = {
            root = ./.github/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              action-validator
              zizmor
            ];
            script = ''
              action-validator "$file"
              zizmor --offline "$file"
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
        };
      }
    );
}
