# Publishing This Flake

## To GitHub

### 1. Create a Repository

```bash
cd /home/gareth/code/flakes/playwright
git init
git add .
git commit -m "Initial commit: Playwright Nix flake"
```

Create a repo on GitHub (e.g., `playwright-flake`), then:

```bash
git remote add origin git@github.com:yourusername/playwright-flake.git
git push -u origin main
```

### 2. Tag a Release

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 3. Usage by Others

Once published, others can use it as:

```nix
inputs.playwright.url = "github:yourusername/playwright-flake";
```

Or with a specific version:

```nix
inputs.playwright.url = "github:yourusername/playwright-flake/v1.0.0";
```

## To FlakeHub (Recommended)

[FlakeHub](https://flakehub.com) is a registry for Nix flakes that provides better versioning and discovery.

### 1. Sign Up

Visit https://flakehub.com and create an account.

### 2. Publish

```bash
# Install flakehub CLI
nix profile install github:DeterminateSystems/flakehub

# Publish (from the flake directory)
flakehub publish
```

### 3. Usage by Others

```nix
inputs.playwright.url = "https://flakehub.com/f/yourusername/playwright-flake/*.tar.gz";
```

## As a Template

Once published to GitHub, others can initialize new projects:

```bash
nix flake init -t github:yourusername/playwright-flake
```

The template is defined in `flake.nix`:

```nix
templates.default = {
  path = ./.;
  description = "Playwright development environment with browser dependencies";
  welcomeText = "...";
};
```

## Version Pinning Best Practices

### For Production Projects

Pin to a specific commit for maximum reproducibility:

```nix
inputs.playwright.url = "github:yourusername/playwright-flake?rev=abc123def456";
```

### For Development

Use the latest from main:

```nix
inputs.playwright.url = "github:yourusername/playwright-flake";
```

### For Testing

Use a local path while developing:

```nix
inputs.playwright.url = "path:/home/gareth/code/flakes/playwright";
```

## Documentation

Make sure to update URLs in the documentation before publishing:

1. **README.md** - Replace placeholder URLs with actual GitHub URLs
2. **USAGE.md** - Update example URLs
3. **QUICKREF.md** - Update references
4. **examples/*.nix** - Update input URLs

Search and replace:
```bash
find . -type f -name "*.md" -o -name "*.nix" | \
  xargs sed -i 's|github:yourusername/playwright-flake|github:ACTUAL_USERNAME/playwright-flake|g'

find . -type f -name "*.nix" | \
  xargs sed -i 's|path:/home/gareth/code/flakes/playwright|github:ACTUAL_USERNAME/playwright-flake|g'
```

## Binary Cache (Optional but Recommended)

Set up Cachix to speed up builds for users:

```bash
# Install cachix
nix-env -iA cachix -f https://cachix.org/api/v1/install

# Create cache
cachix authtoken YOUR_TOKEN
cachix create playwright-flake

# Push derivations
nix build
cachix push playwright-flake ./result
```

Then users can add to their config:

```nix
# nix.conf or flake
substituters = [
  "https://cache.nixos.org"
  "https://playwright-flake.cachix.org"
];
trusted-public-keys = [
  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  "playwright-flake.cachix.org-1:YOUR_KEY_HERE"
];
```

## CI/CD for the Flake

Add GitHub Actions to test the flake:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
        with:
          nix_path: nixpkgs=channel:nixos-unstable

      - name: Check flake
        run: nix flake check

      - name: Build devShell
        run: nix build .#devShells.x86_64-linux.default

      - name: Test in shell
        run: |
          nix develop --command bash -c "
            echo 'Testing environment variables...'
            [ -n \"$PLAYWRIGHT_BROWSERS_PATH\" ] || exit 1
            [ \"$PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD\" = \"1\" ] || exit 1
            command -v pw || exit 1
            echo 'All checks passed!'
          "
```

## Versioning Strategy

### Semantic Versioning

- **v1.0.0** - Initial stable release
- **v1.1.0** - Add new features (backward compatible)
- **v1.0.1** - Bug fixes
- **v2.0.0** - Breaking changes

### What Constitutes Breaking Changes

- Removing exported library functions
- Changing function signatures
- Removing packages from `playwrightPackages`
- Changing environment variable names

### Changelog

Maintain a CHANGELOG.md:

```markdown
# Changelog

## [1.0.0] - 2026-02-10

### Added
- Initial release
- Support for Chromium, Firefox, and WebKit
- `pw` helper command
- Five composition examples
- Complete documentation

### Changed
- Migrated from xorg.* to direct X11 package names
```

## Community

Consider adding:

- **CONTRIBUTING.md** - How others can contribute
- **CODE_OF_CONDUCT.md** - Community guidelines
- **LICENSE** - MIT, Apache, etc.
- **GitHub Discussions** - For Q&A
- **GitHub Issues Templates** - For bug reports and features

## Marketing

Share your flake:

1. **Nix Discourse** - https://discourse.nixos.org
2. **r/NixOS** - Reddit community
3. **Nix Weekly** - Submit to newsletter
4. **Twitter/Mastodon** - #NixOS hashtag
5. **Playwright Discord** - Share in community

## Maintenance

Regular maintenance tasks:

- Update nixpkgs input monthly
- Test with latest Playwright versions
- Monitor issues and PRs
- Update documentation as Playwright evolves
- Keep examples working

## Success Metrics

Track usage via:

- GitHub stars
- FlakeHub downloads
- GitHub Insights traffic
- Issues/discussions activity
