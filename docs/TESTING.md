# Testing SifOS Before GitHub Push

This guide shows you how to validate your SifOS configuration changes before pushing to GitHub.

## Quick Test (Recommended)

Run the automated test suite to check all machine types:

```bash
../scripts/test-build.sh
```

This will:
- ✓ Test each machine type can build successfully
- ✓ Catch syntax errors and duplicate definitions
- ✓ Validate imports and dependencies
- ✓ Take ~30 seconds to run

**Pass criteria**: All 5 machine types (thin-client, office, workstation, shop-kiosk, custom) must pass.

---

## Manual Testing Options

### 1. Syntax Check Only (Fast)
Quick validation without full build:

```bash
nix-instantiate --eval -E '(import <nixpkgs/nixos> { configuration = ./configuration.nix; }).config.system.build.toplevel.drvPath'
```

**Pro**: Very fast (2-3 seconds)  
**Con**: Only checks current machine-config.nix setting, not all types

### 2. Test Specific Machine Type
Test a specific configuration:

```bash
# Edit machine-config.nix to import the type you want to test
# Then run:
nix-build '<nixpkgs/nixos>' -A system -I nixos-config=./configuration.nix
```

**Pro**: Full build validation  
**Con**: Slow (5-10 minutes), downloads packages

### 3. Dry-Run Build
Simulate a full build without downloading:

```bash
nixos-rebuild dry-build -I nixos-config=./configuration.nix
```

**Pro**: Shows what would be built  
**Con**: Requires NixOS system

---

## Common Errors Caught by Testing

### Duplicate Definitions
```
error: attribute 'services.xserver.something' already defined
```
**Fix**: Remove duplicate option or merge into one definition

### Missing Files
```
error: file '/path/to/file.nix' not found
```
**Fix**: Check import paths, create missing files

### Syntax Errors
```
error: syntax error, unexpected '}'
```
**Fix**: Check nix syntax (brackets, semicolons, commas)

### Invalid Options
```
error: The option 'services.something' does not exist
```
**Fix**: Check NixOS manual for correct option names

---

## Testing Workflow

### Before Committing

1. **Run test suite**:
   ```bash
   ../scripts/test-build.sh
   ```

2. **Check git status**:
   ```bash
   git status
   ```

3. **Review changes**:
   ```bash
   git diff
   ```

4. **Commit if tests pass**:
   ```bash
   git add .
   git commit -m "Your descriptive message"
   ```

### Before Pushing to GitHub

1. **Run tests one more time**:
   ```bash
   ../scripts/test-build.sh
   ```

2. **Push to GitHub**:
   ```bash
   git push
   ```

### After Pushing

Optional: Test deployment to a test machine:

```bash
./remote-deploy.sh -t 192.168.0.50 -h test-machine -m thin-client
```

---

## Test Machine Setup

For safer testing, use a dedicated test machine:

1. **Add to inventory**:
   ```
   test-thin:192.168.0.50:thin-client:Test machine for validation
   ```

2. **Deploy to test first**:
   ```bash
   ./remote-deploy.sh -t 192.168.0.50 -h test-thin -m thin-client
   ```

3. **Verify it works**, then deploy to production machines

---

## Continuous Testing

### Git Pre-Push Hook (Optional)

Automatically test before every push:

```bash
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
echo "Running tests before push..."
../scripts/test-build.sh || {
    echo "Tests failed! Push cancelled."
    exit 1
}
EOF

chmod +x .git/hooks/pre-push
```

Now tests run automatically before `git push`.

---

## What Tests DON'T Catch

Tests validate syntax and build logic, but don't catch:

- ❌ Runtime errors (service failures)
- ❌ Hardware compatibility issues
- ❌ Network configuration problems
- ❌ User permission issues
- ❌ Performance problems

**Solution**: Always deploy to a test machine first, then roll out to fleet.

---

## Troubleshooting Test Failures

### "Cannot find nixpkgs"
```bash
# Make sure you're in the sif-os directory
cd /home/darren/sif-os

# Or set NIX_PATH
export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos
```

### "Permission denied"
```bash
chmod +x test-build.sh
```

### "Test hangs"
- Press Ctrl+C to cancel
- Check for syntax errors in recent changes
- Try manual syntax check first

---

## Quick Reference

| Command | Purpose | Speed | Reliability |
|---------|---------|-------|-------------|
| `../scripts/test-build.sh` | Test all types | ~30s | ⭐⭐⭐⭐⭐ |
| `nix-instantiate ...` | Syntax check | ~3s | ⭐⭐⭐ |
| `nix-build ...` | Full build test | ~10m | ⭐⭐⭐⭐⭐ |
| Deploy to test machine | Real-world test | ~5m | ⭐⭐⭐⭐⭐ |

---

## Best Practices

1. ✓ **Always run `../scripts/test-build.sh` before pushing**
2. ✓ Test on dedicated test machine before production
3. ✓ Keep test machine configuration close to production
4. ✓ Review git diff before committing
5. ✓ Write descriptive commit messages
6. ✓ Test one machine type at a time when making big changes
7. ✓ Keep backups of working configurations

---

## See Also

- [Deployment Guide](DEPLOYMENT.md) - How to deploy after testing
- [Fleet Management](FLEET-MANAGEMENT.md) - Managing multiple machines
- [Quick Start](QUICKSTART.md) - Getting started guide
