# Playwright Flake Usage Guide

## Standalone Usage

Use this flake directly for a Playwright-focused project:

```bash
cd my-project
nix flake init -t path:/home/gareth/code/flakes/playwright
nix develop
```

Or from a git repository:
```bash
nix flake init -t github:yourusername/playwright-flake
```

## Composition in Existing Projects

### Option 1: Helper Function (Recommended)

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    playwright.url = "github:yourusername/playwright-flake";
  };

  outputs = { nixpkgs, playwright, ... }:
    # ... your system setup ...
    {
      devShells.default = playwright.lib.${system}.mkPlaywrightShell {
        additionalPackages = with pkgs; [
          nodejs_22
          # your other tools
        ];
        additionalShellHook = ''
          echo "Welcome to my project!"
        '';
      };
    };
}
```

### Option 2: Manual Composition

For more control:

```nix
{
  inputs.playwright.url = "github:yourusername/playwright-flake";

  outputs = { nixpkgs, playwright, ... }:
    let
      pw = playwright.lib.${system};
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [ /* your packages */ ] ++ pw.playwrightPackages;
        shellHook = pw.playwrightShellHook + ''
          # your shell hook
        '';
      };
    };
}
```

## Available Exports

### Packages

- **`playwright-driver.browsers`** - Chromium, Firefox, and WebKit browsers
- **`playwrightScripts`** - The `pw` command-line helper

### Library Functions

#### `mkPlaywrightShell`

Create a development shell with Playwright pre-configured:

```nix
playwright.lib.${system}.mkPlaywrightShell {
  additionalPackages = [ /* your packages */ ];
  additionalShellHook = "echo 'Hello!'";
}
```

#### `playwrightPackages`

List of Playwright-related packages:

```nix
packages = with pkgs; [
  myPackage
] ++ playwright.lib.${system}.playwrightPackages;
```

#### `playwrightShellHook`

Shell hook that configures environment variables:

```nix
shellHook = ''
  ${playwright.lib.${system}.playwrightShellHook}
  echo "Playwright configured!"
'';
```

#### `playwrightDeps`

List of system library dependencies (for custom LD_LIBRARY_PATH):

```nix
buildInputs = myDeps ++ playwright.lib.${system}.playwrightDeps;
```

## The `pw` Helper Command

Once in the dev shell, use the `pw` command:

```bash
pw              # Show help
pw test         # Run all tests
pw test login   # Run specific test
pw ui           # Interactive UI mode
pw debug tests/login.spec.ts  # Debug a test
pw codegen https://example.com # Generate test code
pw show-report  # View HTML report
```

All commands are aliases for `pnpm exec playwright [command]`, so you can pass any Playwright flags:

```bash
pw test --headed           # Run in headed mode
pw test --project=chromium # Run only Chromium tests
pw test --debug           # Debug mode
```

## Environment Variables Set

When you enter the dev shell, these are automatically configured:

- **`PLAYWRIGHT_BROWSERS_PATH`** - Points to Nix-provided browsers
- **`PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD`** - Prevents downloading browsers
- **`PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS`** - Skips host validation
- **`LD_LIBRARY_PATH`** - Includes all required system libraries

## Common Workflows

### Starting a New Project

```bash
# Create project directory
mkdir my-playwright-project && cd my-playwright-project

# Initialize with Playwright flake
nix flake init -t github:yourusername/playwright-flake

# Enter dev shell
nix develop

# Initialize package.json
pnpm init

# Add Playwright
pnpm add -D playwright @playwright/test

# Create Playwright config (will use Nix browsers automatically)
pnpm create playwright

# Run tests
pw test
```

### Adding to Existing Project

```bash
# Add playwright input to flake.nix
# (see composition examples above)

# Update flake
nix flake update

# Enter new shell
nix develop

# Playwright is ready - no 'playwright install' needed!
pw test
```

### CI/CD Integration

GitHub Actions example:

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: cachix/install-nix-action@v20
        with:
          nix_path: nixpkgs=channel:nixos-unstable

      - name: Setup environment
        run: |
          nix develop --command pnpm install

      - name: Run tests
        run: nix develop --command pw test

      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

## Troubleshooting

### "Browser executable doesn't exist"

Make sure you're in the Nix dev shell:
```bash
nix develop
echo $PLAYWRIGHT_BROWSERS_PATH  # Should show a path
```

### "Missing library" errors

The flake should include all dependencies, but if you see errors:
1. Check that `LD_LIBRARY_PATH` is set: `echo $LD_LIBRARY_PATH`
2. Verify you're on Linux (browsers need different deps on macOS)
3. Open an issue with the missing library name

### Slow shell startup

First time is slow (downloading ~1-2GB of browsers). Subsequent times are instant.

To speed up:
- Use binary cache: `cachix use nix-community`
- Use stable nixpkgs for better cache coverage
- Create separate shells for different workflows (see examples/)

### Tests fail with "Cannot find browser"

Don't run `playwright install` - it conflicts with Nix browsers. If you accidentally did:
```bash
rm -rf ~/.cache/ms-playwright
exit  # exit and re-enter the shell
nix develop
```

## Updating

Update the Playwright browsers and dependencies:

```bash
nix flake update
nix develop  # Will rebuild with new versions
```

## More Examples

See the `examples/` directory for:
- Basic composition
- Helper function usage
- Multiple shells
- Monorepo setup
- Multi-flake composition

Read `examples/README.md` for detailed explanations.
