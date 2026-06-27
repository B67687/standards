# Secrets Management Standard

## Domains

security


## Purpose

Keep secrets out of git history. Encrypt `.env` files at rest, store the encrypted version in git, and decrypt only at runtime. This prevents credential leaks while keeping secrets deployable.

## Tools

| Tool | Role |
|------|------|
| **[sops](https://getsops.io)** | Encrypts/decrypts structured files (YAML, JSON, env) — encrypts values only, leaves keys visible |
| **[age](https://age-encryption.org)** | Simple, modern file encryption — sops uses it as a key backend |

## File Naming

| File | In Git? | Purpose |
|------|---------|---------|
| `.env` | ❌ `.gitignore` | Local dev secrets, never committed |
| `.env.encrypted` | ✅ Yes | Encrypted version of .env via sops |
| `.sops.yaml` | ✅ Yes | sops configuration (encryption rules, recipients) |
| `secrets.enc.yaml` | ✅ Yes | Encrypted YAML/JSON secrets |
| `age-key.txt` | ❌ Never | Age private key — NEVER commit, keep offline |
| `.env.*.local` | ❌ `.gitignore` | Per-environment local overrides |

## Workflow

### 1. Generate an age keypair

```bash
age-keygen -o ~/.config/sops/age/keys.txt
# Output:
# Public key: age1yt3tfqlfrwdwx0z0ynwplcr6qxcxfaqycuprpmy89nr83ltx74tqdpszlw
```

The key file is your **root credential** — protect it like a password. Store it in `~/.config/sops/age/keys.txt` (sops discovers this automatically).

### 2. Create `.sops.yaml` at repo root

```yaml
# .sops.yaml
creation_rules:
  - age: >-
      age1yt3tfqlfrwdwx0z0ynwplcr6qxcxfaqycuprpmy89nr83ltx74tqdpszlw
```

For multiple environments:

```yaml
creation_rules:
  - path_regex: \.dev\.enc\.yaml$
    age: 'age1devkey...'
  - path_regex: \.prod\.enc\.yaml$
    age: 'age1prodkey...'
  - path_regex: \.env\.encrypted$
    age: 'age1defaultkey...'
```

### 3. Encrypt your .env

```bash
# After editing .env, encrypt it for git
sops encrypt .env > .env.encrypted
```

### 4. Decrypt at runtime (local)

sops discovers the age key automatically from the first available:

1. `SOPS_AGE_KEY` env var (raw key string) — best for CI
2. `SOPS_AGE_KEY_FILE` env var (path to key file)
3. `~/.config/sops/age/keys.txt`

```bash
sops decrypt .env.encrypted > .env
```

### 5. Decrypt in CI

Set the age private key as a CI secret, then:

```yaml
# GitHub Actions
- name: Decrypt secrets
  env:
    SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
  run: |
    sops decrypt --output-type dotenv .env.encrypted > .env
```

## Gitignore Rules

Add these patterns to `.gitignore`:

```gitignore
# Secrets — never tracked
.env
.env.*
.env.*.local
age-key.txt
*.age
```

## .gitattributes for Cleartext Diffs

To see meaningful diffs on encrypted files (decrypted diff):

```gitignore
*.encrypted diff=sopsdiffer
```

```bash
git config diff.sopsdiffer.textconv "sops decrypt"
```

## `scripts/tools/setup-env-enc.sh`

A setup script is available at `scripts/tools/setup-env-enc.sh` that:

1. Generates an age keypair (if none exists)
2. Creates `.sops.yaml` with the public key
3. Adds `.env` to `.gitignore` (if not already present)
4. Creates `.gitattributes` for cleartext diffs
5. Provides instructions for CI setup

## Edge Cases

### Rotating Keys

1. Add the new public key to `.sops.yaml`
2. Run `sops updatekeys -y .env.encrypted` to re-encrypt for the new key
3. Run `sops rotate -i .env.encrypted` to generate a new data key
4. Remove the old key from `.sops.yaml`

### Multiple Recipients

Add multiple age keys so any recipient can decrypt:

```yaml
creation_rules:
  - age: >-
      age1key1...,
      age1key2...,
      age1key3...
```

### Editing Encrypted Files

```bash
# Opens decrypted content, re-encrypts on save
sops edit .env.encrypted
```

### Converting Existing Secrets

If secrets were ever committed to git, assume they're compromised. Rotate all credentials and regenerate keys.

## Secrets Vaults

For teams with multiple environments (dev/staging/prod) or shared secrets across repos, consider a **secrets vault** instead of (or alongside) sops:

| Vault | Use Case | Best For |
|-------|----------|----------|
| **GitHub Actions Secrets** | Per-repo secrets injected as env vars at CI runtime | CI-only secrets, no local dev needed |
| **HashiCorp Vault** | Dynamic secrets, rotation policies, audit logging | Enterprise, multi-service, zero-trust |
| **Doppler** | Environment-wide secret sync with CLI + CI integration | Teams that need per-environment config without managing keys |
| **1Password CLI** | Developer-friendly, syncs with team vault | Small teams already using 1Password |

**Rule of thumb:** sops/age for per-repo secrets committed to git (our standard); vault for secrets that change per-environment or must be rotated centrally. Both can coexist — use sops for `.env.encrypted` in git and vault for CI runtime secrets.

## Complementary Tools: Gitleaks

While sops/age encrypts `.env` files at rest, **[Gitleaks](https://github.com/gitleaks/gitleaks)** detects accidentally committed secrets by scanning git history.

### Recommended: Gitleaks Pre-Commit Hook

Add Gitleaks as a pre-commit hook to catch secrets before they reach the index:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.20.0
    hooks:
      - id: gitleaks
```

If using lefthook:

```yaml
# lefthook.yml
pre-commit:
  commands:
    secrets:
      run: gitleaks protect --staged --verbose
```

### CI Integration

Run Gitleaks in CI for an additional safety net (catches secrets that bypass local hooks):

```yaml
# .github/workflows/ci.yml
- name: Gitleaks secrets scan
  run: gitleaks detect --no-git --verbose
```

The `--no-git` flag scans files in the working tree without needing the full git history. Use `gitleaks detect` (full history scan) for a thorough audit on release branches.

## Reference

- [sops documentation](https://getsops.io/docs/)
- [age documentation](https://age-encryption.org)
- [sops GitHub](https://github.com/getsops/sops)
