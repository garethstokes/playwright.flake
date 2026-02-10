{
  description = "Playwright development environment with browser dependencies";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Playwright browser runtime dependencies
        # These libraries are required for Chromium, Firefox, and WebKit to run
        playwrightDeps = with pkgs; [
          # Core C++ standard library
          stdenv.cc.cc.lib

          # X11 display server libraries (required for GUI)
          libx11
          libxcb
          libxext
          libxrandr
          libxcomposite
          libxcursor
          libxdamage
          libxfixes
          libxi
          libxrender

          # GTK3 and graphics stack (required for WebKit and Chromium UI)
          gtk3
          pango
          cairo
          gdk-pixbuf
          glib
          atk

          # Graphics drivers and rendering
          libdrm
          mesa

          # Media and audio
          alsa-lib

          # Font rendering
          freetype
          fontconfig

          # System libraries
          dbus
          expat
          cups
          nspr
          nss
        ];

        # Helper scripts for common Playwright tasks
        playwrightScripts = pkgs.writeScriptBin "pw" ''
          #!${pkgs.bash}/bin/bash
          case "$1" in
            test)
              shift
              pnpm exec playwright test "$@"
              ;;
            ui)
              pnpm exec playwright test --ui "$@"
              ;;
            show-report)
              pnpm exec playwright show-report "$@"
              ;;
            codegen)
              pnpm exec playwright codegen "$@"
              ;;
            debug)
              shift
              PWDEBUG=1 pnpm exec playwright test "$@"
              ;;
            *)
              echo "Playwright helper commands:"
              echo "  pw test [args]        - Run tests"
              echo "  pw ui                 - Run tests in UI mode"
              echo "  pw show-report        - Show HTML report"
              echo "  pw codegen [url]      - Generate test code"
              echo "  pw debug [test]       - Debug a test"
              ;;
          esac
        '';

        # Exported packages for composition
        playwrightPackages = with pkgs; [
          playwright-driver.browsers
          playwrightScripts
        ];

        # Exported shell hook for composition
        playwrightShellHook = ''
          # Configure Playwright to use Nix-provided browsers
          export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
          export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
          export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true

          # Add browser runtime dependencies to library path
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath playwrightDeps}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
        '';

      in
      {
        # Standalone development shell
        devShells.default = pkgs.mkShell {
          name = "playwright-dev";

          packages = with pkgs; [
            # Node.js and package managers
            nodejs_22
            nodePackages.pnpm

            # Language servers for editor support
            vscode-langservers-extracted
            tailwindcss-language-server

            # Playwright browsers (Chromium, Firefox, WebKit)
            playwright-driver.browsers

            # Helper scripts
            playwrightScripts
          ];

          shellHook = ''
            ${playwrightShellHook}

            # Welcome message
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🎭 Playwright Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Browsers: Chromium, Firefox, WebKit (provided by Nix)"
            echo "Node.js: $(node --version)"
            echo "pnpm: $(pnpm --version)"
            echo ""
            echo "Quick commands:"
            echo "  pw           - Show Playwright helper commands"
            echo "  pw test      - Run tests"
            echo "  pw ui        - Run tests in UI mode"
            echo "  pw debug     - Debug tests"
            echo ""
            echo "📦 No need to run 'playwright install' - browsers ready!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
          '';
        };

        # Export composable parts for other flakes
        lib = {
          # Function to create a Playwright-enabled shell
          mkPlaywrightShell = { additionalPackages ? [], additionalShellHook ? "" }:
            pkgs.mkShell {
              packages = playwrightPackages ++ additionalPackages;
              shellHook = playwrightShellHook + "\n" + additionalShellHook;
            };

          # Export components for manual composition
          inherit playwrightPackages playwrightShellHook playwrightDeps;
        };

        # Backwards compatibility
        devShell = self.devShells.${system}.default;
      }
    ) // {
      # Flake template for easy project initialization
      templates.default = {
        path = ./.;
        description = "Playwright development environment with browser dependencies";
        welcomeText = ''
          # Playwright Development Environment

          You've initialized a Playwright development environment!

          ## Next steps:

          1. Enter the development shell:
             nix develop

          2. Initialize your project:
             pnpm init
             pnpm add -D playwright @playwright/test

          3. Run Playwright commands using the 'pw' helper:
             pw test
             pw ui
             pw codegen

          ## Composition:

          This flake can be used as an input in other flakes. See examples/ directory
          for different composition patterns.

          ## Documentation:

          - examples/README.md - Composition patterns and usage examples
          - flake.nix - Main configuration with exported lib functions
        '';
      };
    };
}
