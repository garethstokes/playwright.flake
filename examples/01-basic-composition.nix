# Example 1: Basic composition - add Playwright to an existing project
#
# Use this in your project's flake.nix to add Playwright testing capabilities
# alongside your existing development tools.

{
  description = "My web app with Playwright testing";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Add the Playwright flake as an input
    playwright.url = "path:/home/gareth/code/flakes/playwright";
    # Or from a git repo:
    # playwright.url = "github:yourusername/playwright-flake";
  };

  outputs = { self, nixpkgs, flake-utils, playwright }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Get Playwright components from the input
        pw = playwright.lib.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Your existing tools
            nodejs_22
            nodePackages.typescript

            # Add Playwright packages
          ] ++ pw.playwrightPackages;

          shellHook = ''
            # Your existing setup
            echo "Setting up web app dev environment..."

            # Add Playwright configuration
            ${pw.playwrightShellHook}

            echo "✅ Playwright testing ready!"
          '';
        };
      }
    );
}
