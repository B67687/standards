# Audit System Architecture

**Date:** 2026-06-23
**Status:** Accepted
**Last Reviewed:** 2026-06-25

## Context

The standards repo needed a mechanism to enforce its own conventions across multiple projects. Manual compliance checking was slow and inconsistent.

## Decision

Build a centralized audit system with the following architecture:

- Shell-based checks for deterministic rules (file existence, grep, format validation)
- Agent-based evaluations for subjective quality judgments (README quality, badge accessibility)
- Plugin architecture: drop a check file in `scripts/checks/`, auto-registered
- Terminal + JSON output for human and machine consumption
- `--fix` mode for automated remediation of common issues
- Cross-repo dashboard for organizational compliance tracking

## Rationale

A centralized audit system ensures consistent enforcement across all repos. Shell checks cover the deterministic cases, while agent evaluation handles subjective quality. The plugin architecture makes it easy to add new standards without modifying the runner.

## Consequences

- Positive: Deterministic, repeatable audits across all repos
- Positive: Easy to add new standards — just write a check script
- Positive: Self-auditing — the repo audits itself
- Negative: Agent-based checks require human or LLM review (cannot auto-pass)
- Negative: Batch audit is sequential (one repo at a time)
