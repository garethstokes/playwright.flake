# Example 2: Using the helper function - cleanest approach
#
# The mkPlaywrightShell function handles all Playwright setup for you.
# Just pass in your additional tools.

{
  description = "Project using Playwright helper function";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    playwright.url = "path:/home/gareth/code/flakes/playwright";
  };

  outputs = { self, nixpkgs, flake-utils, playwright }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Use the helper function to create a shell with Playwright + your tools
        devShells.default = playwright.lib.${system}.mkPlaywrightShell {
          additionalPackages = with pkgs; [
            # Add your project-specific tools here
            nodejs_22
            nodePackages.typescript
            nodePackages.eslint
            tailwindcss
            postgresql
          ];

          additionalShellHook = ''
            # Your project-specific setup
            echo "🚀 Starting project dev environment..."

            # Setup database
            export DATABASE_URL="postgresql://localhost/myapp"

            # Custom aliases
            alias test="pw test"
            alias dev="pnpm dev"

            echo "✅ Ready to develop!"
          '';
        };
      }
    );
}
