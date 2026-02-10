# Example 5: Composing with multiple input flakes
#
# Combine Playwright with other reusable flakes for a complete environment.
# This shows how to integrate multiple specialized flakes together.

{
  description = "Project combining multiple flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Different specialized flakes
    playwright.url = "path:/home/gareth/code/flakes/playwright";
    # python-dev.url = "github:yourorg/python-dev-flake";
    # rust-tools.url = "github:yourorg/rust-tools-flake";
  };

  outputs = { self, nixpkgs, flake-utils, playwright }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pw = playwright.lib.${system};

        # If you had other flakes:
        # python = python-dev.lib.${system};
        # rust = rust-tools.lib.${system};

      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Your core tools
            nodejs_22
            python311
            rustc
            cargo

            # Add Playwright
          ] ++ pw.playwrightPackages;

          # If you had other flakes, you'd combine their deps too:
          # ] ++ pw.playwrightPackages
          #   ++ python.pythonPackages
          #   ++ rust.rustToolchain;

          shellHook = ''
            # Combine shell hooks from multiple flakes
            ${pw.playwrightShellHook}

            # If you had other flakes:
            # ${python.pythonShellHook}
            # ${rust.rustShellHook}

            # Your project setup
            echo "🛠️  Polyglot development environment"
            echo "• Node.js + Playwright"
            echo "• Python"
            echo "• Rust"
          '';
        };
      }
    );
}
