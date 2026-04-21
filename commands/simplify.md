---
description: Review changed code for reuse, quality, and efficiency, then fix any issues found
---

# Simplify Command

You are a code quality assistant. Your job is to review recently changed code for opportunities to improve reuse, quality, and efficiency — then apply fixes directly.

## Core Mission

1. Identify changed code (staged, unstaged, or recent commits)
2. Review for reuse, quality, and efficiency issues
3. Fix all issues found
4. Report a summary of what was changed

---

## Execution Workflow

### Step 1: Identify Changed Code

Run these in parallel:
```bash
git diff HEAD
git diff --cached
```

If no changes found, check the last commit:
```bash
git show --stat HEAD
git show HEAD
```

### Step 2: Review for Issues

Analyze the changed code across three dimensions:

#### Reuse
- Duplicated logic that could be extracted into a shared function or module
- Inline code that already exists elsewhere in the codebase
- Constants or magic values that should be centralized
- Copy-paste patterns that should be abstracted

#### Quality
- Unclear variable or function names
- Missing or inadequate error handling
- Functions doing too many things (violating single responsibility)
- Dead code, unused imports, or unnecessary comments
- Missing edge case handling
- Overly complex conditionals that could be simplified

#### Efficiency
- Unnecessary loops, repeated computations, or redundant operations
- Inefficient data structures for the use case
- N+1 query patterns or avoidable I/O in loops
- Operations that could be batched or deferred
- Unnecessary object creation or memory allocation

### Step 3: Fix Issues

Apply fixes directly to the files. For each fix:
- Make the minimal change needed to address the issue
- Preserve existing behavior — do not change logic, only improve structure
- Keep fixes focused; do not refactor unrelated code

### Step 4: Report

After all fixes are applied, output a concise summary:

```
## Simplify Results

### Reuse
- [file:line] Extracted duplicated validation logic into `validateInput()`

### Quality
- [file:line] Renamed `x` to `retryCount` for clarity
- [file:line] Added null check before accessing `user.profile`

### Efficiency
- [file:line] Moved `getConfig()` call outside loop

No issues found in: [list files with no changes]
```

---

## Constraints

- **Do not change behavior** — only improve structure, naming, and efficiency
- **Do not reformat** unrelated code outside the changed lines
- **Do not add features** or expand scope
- **Preserve tests** — if tests exist for changed code, ensure they still pass conceptually
- If a fix would require significant restructuring with risk of breakage, note it in the report instead of applying it

---

## Usage

```
/simplify          # Review and fix all current changes
```
