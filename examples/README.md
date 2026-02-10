# Playwright Flake Composition Examples

This directory contains examples showing how to compose the Playwright flake with your projects.

## Quick Start

The Playwright flake exports these composable parts:

```nix
playwright.lib.${system}.playwrightPackages     # Browser and helper script packages
playwright.lib.${system}.playwrightShellHook    # Environment variables and LD_LIBRARY_PATH
playwright.lib.${system}.playwrightDeps         # List of system libraries
playwright.lib.${system}.mkPlaywrightShell      # Helper function to create shells
```

## Composition Patterns

### 1. Basic Composition (`01-basic-composition.nix`)
**When to use:** You have an existing flake and want to add Playwright.

Manually add Playwright packages and shell hooks to your existing development shell.

```bash
# Copy the pattern to your project
cp examples/01-basic-composition.nix ../your-project/flake.nix
```

**Pros:** Full control, easy to understand
**Cons:** More verbose

---

### 2. Helper Function (`02-helper-function.nix`)
**When to use:** You want the cleanest, simplest approach.

Use `mkPlaywrightShell` to automatically set up Playwright with your tools.

```nix
devShells.default = playwright.lib.${system}.mkPlaywrightShell {
  additionalPackages = [ /* your tools */ ];
  additionalShellHook = "echo 'Welcome!'";
};
```

**Pros:** Cleanest, most maintainable
**Cons:** Less flexibility for complex setups

---

### 3. Multiple Shells (`03-multiple-shells.nix`)
**When to use:** Different team members need different environments.

Create specialized shells for different workflows (backend, frontend, fullstack).

```bash
nix develop              # Backend only
nix develop .#frontend   # Frontend + Playwright
nix develop .#fullstack  # Everything
```

**Pros:** Optimized environments, faster load times
**Cons:** More configuration

---

### 4. Monorepo (`04-monorepo.nix`)
**When to use:** Multiple apps in one repository with different needs.

Each app gets its own shell, selectively including Playwright where needed.

```bash
nix develop .#web-app    # With E2E tests
nix develop .#api        # Without browsers
nix develop .#ci         # Everything for CI/CD
```

**Pros:** Per-app optimization, clear boundaries
**Cons:** More shells to maintain

---

### 5. Multiple Flakes (`05-with-other-flakes.nix`)
**When to use:** Combining several reusable flakes.

Import multiple specialized flakes and combine their packages/shell hooks.

**Pros:** Maximum reusability across projects
**Cons:** More complex dependency management

---

## Remote Usage

Instead of using a local path, reference from a git repository:

```nix
inputs = {
  playwright.url = "github:yourusername/playwright-flake";
  # Or with a specific revision:
  # playwright.url = "github:yourusername/playwright-flake?ref=main";
  # Or a specific commit:
  # playwright.url = "github:yourusername/playwright-flake?rev=abc123";
};
```

## Making This Flake a Template

To use this as a template for new projects:

```bash
# In this directory
nix flake init -t /home/gareth/code/flakes/playwright
```

Add this to `flake.nix` to register it as a template:

```nix
templates.default = {
  path = ./.;
  description = "Playwright development environment";
};
```

Then others can use:

```bash
nix flake init -t github:yourusername/playwright-flake
```

## Best Practices

1. **Pin your dependencies** - Use specific commits for reproducibility:
   ```nix
   playwright.url = "github:user/repo?rev=abc123def456";
   ```

2. **Lock your flake** - Commit `flake.lock` to ensure everyone uses the same versions

3. **Use stable nixpkgs** - Unless you need bleeding edge, prefer `nixos-24.11` over `unstable`

4. **Test in CI** - Use the same flake in GitHub Actions:
   ```yaml
   - uses: cachix/install-nix-action@v20
   - run: nix develop --command pw test
   ```

5. **Document available shells** - Include a message in your default shell listing other shells

## Troubleshooting

**Problem:** Browsers don't work after composition
**Solution:** Ensure `playwrightShellHook` is included in your shell hook

**Problem:** Missing libraries error
**Solution:** The `LD_LIBRARY_PATH` might be overwritten. Use:
```nix
export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath playwrightDeps}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
```

**Problem:** Slow to enter shell
**Solution:** Use `nix develop --offline` after first build, or consider creating separate shells for different workflows

## Contributing

Found a useful composition pattern? Add it as a new example!

```bash
# Create your example
cp examples/02-helper-function.nix examples/06-your-pattern.nix

# Document it in this README

# Share it!
```
