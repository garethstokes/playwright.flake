# Playwright Flake Quick Reference

## As a Standalone Flake

```bash
cd my-project
nix flake init -t path:/home/gareth/code/flakes/playwright
nix develop
pw test
```

## As an Input (Composition)

### Add to flake.nix inputs:
```nix
inputs.playwright.url = "github:yourusername/playwright-flake";
```

### Use the helper function (easiest):
```nix
devShells.default = playwright.lib.${system}.mkPlaywrightShell {
  additionalPackages = with pkgs; [ nodejs_22 ];
  additionalShellHook = "echo 'Ready!'";
};
```

### Or compose manually:
```nix
let pw = playwright.lib.${system}; in
pkgs.mkShell {
  packages = [ myPkg ] ++ pw.playwrightPackages;
  shellHook = pw.playwrightShellHook + "echo 'Ready!'";
}
```

## Exported Library

```nix
playwright.lib.${system}
├── mkPlaywrightShell       # Helper function
├── playwrightPackages      # [ browsers, scripts ]
├── playwrightShellHook     # Environment setup
└── playwrightDeps          # System libraries list
```

## The `pw` Command

```bash
pw              # Show help
pw test         # Run tests
pw ui           # UI mode
pw debug [test] # Debug mode
pw codegen [url]# Generate tests
pw show-report  # View report
```

## Common Patterns

### Single project
```nix
devShells.default = pw.mkPlaywrightShell { ... };
```

### Multiple shells
```nix
devShells = {
  backend = pkgs.mkShell { ... };              # No browsers
  frontend = pw.mkPlaywrightShell { ... };     # With Playwright
};
```

### Monorepo
```nix
devShells = {
  web-app = pw.mkPlaywrightShell { ... };
  api = pkgs.mkShell { ... };
  ci = pkgs.mkShell {
    packages = apiPkgs ++ pw.playwrightPackages;
    shellHook = pw.playwrightShellHook;
  };
};
```

## Environment Variables

Set automatically when entering the shell:

- `PLAYWRIGHT_BROWSERS_PATH` → Nix browser location
- `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` → Don't download
- `PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true` → Skip checks
- `LD_LIBRARY_PATH` → All required system libraries

## Key Points

✅ **DO:**
- Use `pw test` to run tests
- Use the flake as an input in your projects
- Commit `flake.lock` for reproducibility
- Use `mkPlaywrightShell` for simplicity

❌ **DON'T:**
- Run `playwright install` (conflicts with Nix)
- Modify `PLAYWRIGHT_BROWSERS_PATH` manually
- Download browsers outside Nix

## Files

```
flake.nix          → Main configuration
USAGE.md           → Complete documentation
examples/          → 5 composition patterns
examples/README.md → Pattern explanations
QUICKREF.md        → This file
```

## Update

```bash
nix flake update              # Update all inputs
nix develop --recreate-lock   # Force rebuild
```

## Resources

- Full docs: `USAGE.md`
- Examples: `examples/`
- Playwright docs: https://playwright.dev
