# Meta-Standard: Minimal Surface Principle

## Rule

Every file in the repository must contain **exactly as much as required, no more and no less**.

Anything extra is a liability:
- Extra **entries** in `.gitignore` leak local directory structure
- Extra **comments** in config files document implementation details that should remain local
- Extra **documentation** of internal processes creates a maintenance burden
- Extra **whitelist entries** reveal file names that should never be mentioned

## Application

| File | What to Strip |
|------|--------------|
| `.gitignore` | Only entries that counteract whitelist patterns. No documentation of local-only files. No section headers. No redundant `!` patterns. |
| `README.md` | Only information the end user needs. No build instructions for internal tooling. No CI configuration details. |
| `CHANGELOG.md` | Only changes users can see. No infrastructure changes, CI updates, or internal refactoring. |
| Config files | Only settings that differ from defaults. No explanatory comments. |
| CI configs | Never push CI configs to GitHub if CI runs locally. |

## Rationale

Every line in a committed file is **public documentation**. It reveals:
- What tooling you use
- What files exist on your local machine
- What processes you run internally
- What conventions you follow

If a file doesn't need to mention something, not mentioning it is the safest option. The absence of information is not a gap — it's a deliberate protection boundary.

## READMEs

README is the most public-facing file. It must not reference:
- Local-only scripts or tools (`review.sh`, `scripts/`, `local CI commands`)
- Local directory structure (`docs/adr/`, `docs/solutions/` — these are empty until filled)
- Local CI infrastructure (cron schedules, local-only tools, package managers)
- Internal processes that only matter to the maintainer

The README should describe what the project IS and how to USE it — not how it's BUILT internally.

## Cleanup All Evidence of Cleanup

There is no such thing as a cleanup commit, a cleanup commit message, or a cleanup branch.

A file that should not exist in the repo must never appear in any commit — not even in a commit that "removes" it. If a file needs to go, its removal must be squashed into a legitimate adjacent commit (feature, fix, refactor) so the removal is invisible among real work.

A commit that exists solely to remove something is evidence that the thing once existed. It doesn't matter what the commit message says — the commit itself is the evidence. The only fix is to squash it away so it was never its own entry in the log.

This applies to: gitignore entries, README edits, config changes, commit messages, changelogs — anything that reveals a removal happened.

## When to Add

Add content only when:
1. A tool REQUIRES it to function (e.g., `.gitignore` patterns)
2. A user NEEDS it to use the project (e.g., README install instructions)
3. A standard MANDATES it (e.g., LICENSE file)

Remove content when:
1. It documents local-only infrastructure
2. It's redundant with a broader pattern
3. It reveals more than necessary about your setup

## Operational Rule: YAGNI

The Minimal Surface Principle is achieved operationally by following **YAGNI (You Ain't Gonna Need It)**:

- Add a config entry only when a tool or workflow actually requires it, not when you anticipate future need
- Add a `.gitignore` entry only when a file actually appears, not as preemptive protection
- Add a README section only when a user actually needs the information, not for completeness
- Remove an entry when the requirement is removed — don't keep "just in case" entries

Every config entry is functionality in configuration space. Adding it before you need it is the config equivalent of adding code before you call it.

## Sources

The Minimal Surface Principle is not novel — it is the convergence of seven established industry principles applied to file content:

| Principle | Source | Relationship |
|-----------|--------|-------------|
| **Rule of Silence** | Unix (McIlroy) | A file should be silent except for what distinguishes it from defaults |
| **Occam's Razor** | William of Ockham | Entities (lines, entries) must not be multiplied beyond necessity |
| **YAGNI** | XP / Ron Jeffries | Add entries only when actually needed, never preemptively |
| **Least Privilege** | Saltzer & Schroeder | Expose only the information necessary for the file's purpose |
| **DRY** | Hunt & Thomas | Every piece of knowledge has one authoritative representation |
| **SSOT** | Information science | Master each fact in exactly one place; curate each location |
| **Chesterton's Fence** | G. K. Chesterton | Before removing an entry, understand why it was added |

### Corollary: Einstein's Razor

Everything should be as simple as possible, **but not simpler**. Minimal does not mean cryptic. A comment explaining why a non-obvious entry exists is not excess — it is part of the required information. The goal is minimal surface, not minimal comprehension.
