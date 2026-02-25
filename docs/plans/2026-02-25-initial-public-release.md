# Initial Public Release Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Prepare `bak` for initial public release with a public-facing README, MIT license, and automated validation that every README example command is valid.

**Architecture:** Keep the shell utility behavior intact, and improve release readiness through documentation and scenario tests. README examples are treated as executable contract: a dedicated scenario test runs the same commands (literal shell lines) in an isolated temp environment. Existing behavior tests remain as guardrails.

**Tech Stack:** POSIX `sh`, existing `bak` script, scenario-based shell tests (`tests/*.sh`), Jujutsu (`jj`).

---

### Task 1: Add release files and README command model

**Files:**
- Modify: `README.md`
- Create: `LICENSE`

**Step 1: Write the failing test**

Create/adjust README to include a deterministic example workflow section using literal shell commands that can be executed in order.

**Step 2: Run test to verify it fails**

Run: `sh tests/readme_examples.sh`
Expected: FAIL because `tests/readme_examples.sh` does not exist yet.

**Step 3: Write minimal implementation**

Implement README + LICENSE content:
- README includes install, safety defaults, and stepwise examples that are executable verbatim.
- LICENSE is MIT.

**Step 4: Run test to verify it passes**

Run: `test -f LICENSE && rg -n "MIT License" LICENSE && rg -n "## Quickstart" README.md`
Expected: PASS with matching output.

**Step 5: Commit**

```bash
jj describe -m "Draft public README and add MIT license"
jj new
```

### Task 2: Add README example execution scenario

**Files:**
- Create: `tests/readme_examples.sh`

**Step 1: Write the failing test**

Create `tests/readme_examples.sh` that executes README examples literally and ends with `echo ok`.

**Step 2: Run test to verify it fails**

Run: `sh tests/readme_examples.sh`
Expected: FAIL initially due to missing setup details or mismatched commands.

**Step 3: Write minimal implementation**

Implement scenario script with:
- isolated temp dir,
- local `HOME`,
- literal execution of README commands in order,
- assertions around expected outputs and file states.

**Step 4: Run test to verify it passes**

Run: `sh tests/readme_examples.sh`
Expected: PASS and final `ok`.

**Step 5: Commit**

```bash
jj describe -m "Add README example scenario test"
jj new
```

### Task 3: Verify full scenario suite and release hygiene

**Files:**
- Modify: `tests/scenario.sh` (only if needed)
- Modify: `.gitignore` (only if needed)

**Step 1: Write the failing test**

Run the full scenario set and capture regressions.

**Step 2: Run test to verify it fails**

Run:
- `sh tests/scenario.sh`
- `sh tests/readme_examples.sh`

Expected: FAIL if regressions exist.

**Step 3: Write minimal implementation**

Apply only targeted fixes required for deterministic test behavior and release cleanliness.

**Step 4: Run test to verify it passes**

Run:
- `sh tests/scenario.sh`
- `sh tests/readme_examples.sh`

Expected: both PASS.

**Step 5: Commit**

```bash
jj describe -m "Finalize release readiness and verify scenarios"
```
