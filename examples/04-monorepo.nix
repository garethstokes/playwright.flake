# Example 4: Monorepo with multiple apps
#
# Use Playwright in a monorepo where different apps have different needs.
# Each app can selectively include Playwright.

{
  description = "Monorepo with multiple apps";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    playwright.url = "path:/home/gareth/code/flakes/playwright";
  };

  outputs = { self, nixpkgs, flake-utils, playwright }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pw = playwright.lib.${system};

        # Common packages used across all apps
        commonPackages = with pkgs; [
          nodejs_22
          nodePackages.pnpm
          nodePackages.turbo
        ];

      in
      {
        devShells = {
          # Default: root of monorepo
          default = pkgs.mkShell {
            packages = commonPackages;
            shellHook = ''
              echo "📦 Monorepo root"
              echo ""
              echo "Available shells:"
              echo "  nix develop .#web-app      - Web app with E2E tests"
              echo "  nix develop .#api          - API server"
              echo "  nix develop .#marketing    - Marketing site with E2E"
            '';
          };

          # Web app: needs Playwright for E2E tests
          web-app = pw.mkPlaywrightShell {
            additionalPackages = commonPackages ++ (with pkgs; [
              nodePackages.typescript
              nodePackages.vite
            ]);

            additionalShellHook = ''
              cd apps/web
              echo "🎭 Web app with E2E testing"
            '';
          };

          # API: no browser needed
          api = pkgs.mkShell {
            packages = commonPackages ++ (with pkgs; [
              postgresql
              redis
            ]);

            shellHook = ''
              cd apps/api
              echo "🔧 API development"
            '';
          };

          # Marketing site: also needs Playwright
          marketing = pw.mkPlaywrightShell {
            additionalPackages = commonPackages ++ (with pkgs; [
              nodePackages.next
            ]);

            additionalShellHook = ''
              cd apps/marketing
              echo "📢 Marketing site with E2E testing"
            '';
          };

          # CI/CD: everything for running all tests
          ci = pkgs.mkShell {
            packages = commonPackages ++ pw.playwrightPackages ++ (with pkgs; [
              postgresql
              redis
            ]);

            shellHook = ''
              ${pw.playwrightShellHook}
              echo "🤖 CI/CD environment - all tools available"
            '';
          };
        };
      }
    );
}
