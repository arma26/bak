Title: bak backup utility (shell)
Date: 2026-02-24

Goals
- Provide `bak <path>` to create versioned backups for files or directories.
- Provide `bak --revert <path>` to restore the most recent backup by default.
- Provide `bak --version <id>` to select a specific backup for revert.
- Provide `bak --list <path>` to show available versions for the target.
- Preserve permissions/ownership/timestamps.
- Support repeatable `--exclude` globs for directory backup.
- Produce a manifest with hashes for each backup.
- Allow `--root <path>` to override the global backup location per run.

Non-goals
- Cross-host sync or remote storage.
- Content-aware diffs between versions.

CLI
bak [--root PATH] [--exclude GLOB ...] [--list] [--version ID] [--revert] <path>

Behavior
- Default backup root: ~/.bak
- `bak <path>`:
  - Create a new version directory under ~/.bak.
  - Create a tar archive for both files and directories.
  - Generate manifest with:
    - Source path (absolute)
    - Backup root (absolute)
    - Backup version directory (absolute)
    - Archive path (absolute)
    - File list with sha256 per entry (relative to source root)
- `bak --revert <path>`:
  - Restore most recent version by default.
  - If `--version` provided, restore that version.
  - Overwrite existing destination contents.
- `bak --list <path>`:
  - Print available version IDs for the target path (most recent first).

Storage Layout
- Root: ~/.bak
- Target key directory: ~/.bak/<escaped_source_path>/
- Version directory: ~/.bak/<escaped_source_path>/<version_id>/
- Files:
  - data.tar
  - manifest.txt

Version ID
- UTC timestamp with sortable format: YYYYmmddTHHMMSSZ

Excludes
- `--exclude` repeatable.
- For directories, pass globs to `tar --exclude`.
- For files, if the file matches an exclude pattern, error.

Hashing
- Prefer `shasum -a 256`, fallback to `sha256sum`.

Error Handling
- Missing path, unreadable path, bad flags -> exit non-zero with clear error.
- `--version` without `--revert` -> error.
- `--list` without path -> error.

Implementation Notes
- Use guard clauses to avoid deep nesting.
- Use atomic temp files where possible (manifest generation).
- Use portable `sh` script.
