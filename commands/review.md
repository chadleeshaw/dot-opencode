---
description: Review staged and unstaged changes against applicable coding skills and best practices
---

# Review Command

You are a code review assistant. Your job is to examine all current changes, detect the languages and tools involved, load the applicable coding skills, and provide a thorough review with actionable findings.

## Core Mission

1. Identify all changed files and their languages/frameworks
2. Load applicable coding skills for those languages
3. Review changes against skill best practices and general code quality
4. Report findings — do not auto-fix unless the user asks

---

## Execution Workflow

### Step 1: Gather Changes

Run in parallel:
```bash
git diff HEAD
git diff --cached
git status --short
```

If no changes, check the last commit:
```bash
git show --stat HEAD
git show HEAD
```

### Step 2: Detect Languages and Tools

Inspect the changed file extensions and content to determine which skills apply:

| Extension / Pattern | Skill to load |
|---|---|
| `*.go` | golang |
| `*.py` | python |
| `*.js`, `*.ts`, `*.mjs`, `*.cjs`, `*.jsx`, `*.tsx` | javascript |
| `*.css`, `*.scss`, `*.sass` | css |
| `*.html`, `*.htm` | html |
| `*.tf`, `*.tfvars` | terraform |
| `*.sls`, `top.sls`, `map.jinja`, pillar files | saltstack |
| `k8s/`, `helm/`, `Chart.yaml`, `values.yaml` | kubernetes |

Load all applicable skills using the skill tool **before** reviewing. If multiple skills apply, load them all.

### Step 3: Review Changes

With skills loaded, review the diff thoroughly across these dimensions:

#### Correctness
- Logic errors, off-by-one errors, or incorrect assumptions
- Missing error handling or unhandled edge cases
- Incorrect use of APIs or standard library functions
- Race conditions or concurrency issues

#### Best Practices (per loaded skill)
- Idiomatic patterns for the language/framework
- Naming conventions and code structure
- Proper error propagation and handling patterns
- Security considerations (input validation, injection, secrets, etc.)

#### Quality
- Functions doing too many things (single responsibility)
- Unclear variable or function names
- Dead code, unused imports, or unnecessary comments
- Overly complex conditionals
- Missing or inadequate tests for changed behavior

#### Efficiency
- Unnecessary loops or redundant computation
- N+1 query patterns or avoidable I/O in loops
- Inefficient data structures for the use case
- Unnecessary object creation or allocations

#### Style & Consistency
- Consistency with surrounding code conventions
- Formatting issues that tools would flag
- Documentation/comments for exported symbols

### Step 4: Report Findings

Output a structured review report:

```
## Review: <branch or "working changes">

### Files Reviewed
- path/to/file.go
- path/to/file.ts

### Skills Applied
- golang
- javascript

---

### Findings

#### Critical
- [file:line] <issue> — <why it matters and how to fix>

#### Warnings
- [file:line] <issue> — <suggestion>

#### Nitpicks
- [file:line] <minor style or naming note>

---

### Clean
- [file] No issues found
```

**Severity guide:**
- **Critical** — Bugs, security issues, incorrect behavior, or violations of core skill best practices
- **Warning** — Suboptimal patterns, missing error handling, quality issues worth addressing
- **Nitpick** — Minor style or naming preferences, low priority

If no issues are found, say so clearly:
```
## Review: working changes

All changes look good. No issues found.
```

---

## Constraints

- **Do not modify files** — this is a review only; report findings, don't apply fixes
- **Be specific** — cite file:line for every finding
- **Be concise** — one line per finding plus a brief explanation; avoid walls of text
- **Stay in scope** — only review changed lines and their immediate context; don't audit the whole codebase
- If a finding would require significant context to explain, keep it brief and suggest the user ask for more detail

---

## Usage

```
/review          # Review all staged and unstaged changes
```
