# Playwright Development Environment Flake

A production-ready Nix flake that provides a complete Playwright development environment with all browser dependencies pre-configured.

## Features

- 🎭 **All browsers included** - Chromium, Firefox, and WebKit
- 📦 **Zero manual setup** - No `playwright install` needed
- 🔧 **Composable** - Use as input in your own flakes
- 🚀 **Helper commands** - `pw test`, `pw ui`, `pw debug`, etc.
- 🔒 **Reproducible** - Same environment everywhere
- 📚 **Well documented** - 5 composition examples included

## Quick Start

### Standalone Usage

Create a new Playwright project:

```bash
mkdir my-playwright-tests && cd my-playwright-tests
nix flake init -t github:yourusername/playwright-flake
nix develop
```

The `pw` helper is now available:

```bash
pw test         # Run tests
pw ui           # Open UI mode
pw debug        # Debug tests
```

### Add to Existing Project

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    playwright.url = "github:yourusername/playwright-flake";
  };

  outputs = { nixpkgs, playwright, ... }:
    # your system setup
    {
      devShells.default = playwright.lib.${system}.mkPlaywrightShell {
        additionalPackages = with pkgs; [
          nodejs_22
          # your other tools
        ];
      };
    };
}
```

Then:

```bash
nix flake update
nix develop
pw test  # Works immediately!
```

## What's Included

### Packages

- Playwright browsers (Chromium, Firefox, WebKit)
- All required system libraries (X11, GTK3, fonts, etc.)
- `pw` helper command

### Environment Configuration

- `PLAYWRIGHT_BROWSERS_PATH` - Points to Nix-provided browsers
- `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD` - Prevents manual downloads
- `LD_LIBRARY_PATH` - All required native libraries

### Helper Command: `pw`

```bash
pw              # Show all commands
pw test         # Run tests
pw test login   # Run specific test
pw ui           # Interactive UI mode
pw debug [test] # Debug with PWDEBUG=1
pw codegen [url]# Generate test code
pw show-report  # View HTML report
```

## Composition Patterns

This flake exports a library for easy composition:

### Pattern 1: Helper Function (Recommended)

```nix
devShells.default = playwright.lib.${system}.mkPlaywrightShell {
  additionalPackages = [ /* your packages */ ];
  additionalShellHook = "echo 'Welcome!'";
};
```

### Pattern 2: Manual Composition

```nix
let pw = playwright.lib.${system}; in
pkgs.mkShell {
  packages = myPackages ++ pw.playwrightPackages;
  shellHook = pw.playwrightShellHook + "# your hook";
}
```

### Pattern 3: Multiple Shells

```nix
devShells = {
  backend = pkgs.mkShell { /* no browsers */ };
  frontend = pw.mkPlaywrightShell { /* with browsers */ };
};
```

See `examples/` directory for more patterns including monorepo setup and multi-flake composition.

## Exported Library

```nix
playwright.lib.${system}
├── mkPlaywrightShell { additionalPackages, additionalShellHook }
├── playwrightPackages      # List of packages
├── playwrightShellHook     # Shell hook script
└── playwrightDeps          # System library dependencies
```

## Documentation

- **[QUICKREF.md](QUICKREF.md)** - Quick reference card
- **[USAGE.md](USAGE.md)** - Complete usage guide
- **[examples/](examples/)** - 5 composition examples
- **[examples/README.md](examples/README.md)** - Pattern explanations

## Examples

The `examples/` directory contains 5 different composition patterns:

1. **Basic Composition** - Add to existing flake
2. **Helper Function** - Simplest approach
3. **Multiple Shells** - Different environments
4. **Monorepo** - Per-app configuration
5. **Multi-Flake** - Compose with other flakes

Each example is a complete, working `flake.nix` you can copy and adapt.

## Why Use This?

### Without This Flake

```bash
nix develop
npm install playwright
npx playwright install          # Downloads browsers
npx playwright test
# Error: missing libgtk-3.so.0
# Error: missing libX11.so.6
# ... manually install system dependencies
```

### With This Flake

```bash
nix develop
pw test  # Just works! ✨
```

## Requirements

- Nix with flakes enabled
- Linux (x86_64-linux or aarch64-linux)
- macOS support coming soon

## CI/CD

Use in GitHub Actions:

```yaml
- uses: cachix/install-nix-action@v20
- run: nix develop --command pw test
```

The exact same environment runs locally and in CI.

## Updating

Update to latest browser versions:

```bash
nix flake update
```

## Troubleshooting

### "Cannot find browser"

Don't run `playwright install`. The flake provides browsers automatically.

### Missing libraries

If you see missing library errors, please open an issue with the library name.

### Slow first run

First time downloads ~1-2GB of browsers. Subsequent runs are instant.

## Contributing

Contributions welcome! Areas to improve:

- macOS support
- Additional helper commands
- More composition examples
- Performance optimizations

## License

MIT

## Credits

Built with Nix flakes. Inspired by the Playwright and Nix communities.

---

**Quick Links:**
[Quick Reference](QUICKREF.md) | [Usage Guide](USAGE.md) | [Examples](examples/) | [Issues](https://github.com/yourusername/playwright-flake/issues)
