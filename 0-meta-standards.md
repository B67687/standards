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

## No Such Thing as a Cleanup Commit

There is no such thing as a "cleanup commit." Every commit is a permanent public record.

If a file should not exist on GitHub, it must never appear in any commit — not even in a commit that "removes" it. The only way to eliminate evidence of a file's existence is to rewrite history with `git-filter-repo` before the file is ever pushed.

**Rules:**
- Never make cleanup its own commit. A "remove review.sh" commit proves review.sh once existed.
- If a file needs to be removed from the current state, fold the removal into a legitimate change (feature, fix, refactor) so it's invisible among real work.
- If a file has already been committed in a separate cleanup commit, the only fix is `git-filter-repo` to rewrite history — a commit message amendment is not enough.
- The goal is not to rename cleanup commits. The goal is to never make one in the first place.

**Apply to all files:** gitignore entries, README content, commit messages, changelogs, config files. Any mention of a cleanup operation is evidence that one happened.

## When to Add

Add content only when:
1. A tool REQUIRES it to function (e.g., `.gitignore` patterns)
2. A user NEEDS it to use the project (e.g., README install instructions)
3. A standard MANDATES it (e.g., LICENSE file)

Remove content when:
1. It documents local-only infrastructure
2. It's redundant with a broader pattern
3. It reveals more than necessary about your setup
