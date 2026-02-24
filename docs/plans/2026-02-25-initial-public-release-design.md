# Initial Public Release Design

Date: 2026-02-25

## Goals
- Prepare the repository for an initial public release with script-only distribution.
- Publish clear user-facing documentation with literal runnable examples.
- Validate every README example via automated tests that execute commands exactly as written.

## Non-goals
- Package manager distribution (Homebrew, apt, etc.).
- Broad portability refactors for GNU/BSD differences.

## Constraints and Decisions
- Release target: script-only.
- Compatibility target: best-effort cross-platform.
- README example validation: literal command execution.
- License: MIT.
- Existing local changes in `README.md` and `bak` are in scope and will be built on top of.

## Approach
Manual synchronization between README and test scripts:
- README remains the primary published documentation.
- A dedicated scenario test script will execute README example commands literally in sequence.
- README will include deterministic setup commands so examples can run in a temporary environment.

This trades off maintainability for explicitness, but it satisfies the selected requirement to keep documentation authored directly in README while still proving examples are valid.

## Artifacts
- `README.md`: release-oriented rewrite with concise install/usage sections and literal examples.
- `LICENSE`: MIT license text.
- `tests/readme_examples.sh`: executes README examples exactly as written.
- `tests/scenario.sh`: retained and adjusted only if needed for consistency.
- `.gitignore`: updated only if test/release artifacts require exclusions.

## Test Strategy
- Keep existing scenario-based behavioral test.
- Add README example scenario as a separate test entrypoint.
- README example test must:
  - create isolated temp workspace,
  - set environment (including `HOME`) so `~` expansions remain valid,
  - execute each command literally,
  - fail fast on non-zero exit.

Success criteria:
- All tests pass in repository environment.
- README examples run literally and pass.
- Repo includes minimal release files (README + MIT LICENSE).

## Risks and Mitigations
- Drift between README and tests remains possible with manual synchronization.
  - Mitigation: require README example test updates in same change when editing examples.
- Portability differences may affect commands across systems.
  - Mitigation: document best-effort support and avoid platform-specific shell features in examples where possible.
