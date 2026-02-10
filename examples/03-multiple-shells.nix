# Example 3: Multiple development shells
#
# Create different shells for different purposes:
# - Frontend development with Playwright
# - Backend development without browser overhead
# - Full-stack development with everything

{
  description = "Project with multiple dev shells";

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
      in
      {
        devShells = {
          # Default: backend only (no browser overhead)
          default = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              postgresql
              redis
            ];

            shellHook = ''
              echo "🔧 Backend development environment"
              echo "Use 'nix develop .#frontend' for frontend with Playwright"
            '';
          };

          # Frontend: includes Playwright for E2E testing
          frontend = pw.mkPlaywrightShell {
            additionalPackages = with pkgs; [
              nodejs_22
              nodePackages.typescript
              tailwindcss
            ];

            additionalShellHook = ''
              echo "🎨 Frontend development with Playwright testing"
            '';
          };

          # Full-stack: everything combined
          fullstack = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              postgresql
              redis
              tailwindcss
            ] ++ pw.playwrightPackages;

            shellHook = ''
              ${pw.playwrightShellHook}

              echo "🚀 Full-stack development environment"
              echo "Frontend + Backend + E2E Testing"
            '';
          };
        };
      }
    );
}

# Usage:
# nix develop              → backend only
# nix develop .#frontend   → frontend + playwright
# nix develop .#fullstack  → everything
