# bak

Versioned backups for files and directories with fast restore.

## Install

Place `bak` on your `PATH`, for example:

```sh
cp bak /usr/local/bin/bak
```

## Usage

```sh
bak [--root PATH] [--exclude GLOB ...] [--list] [--version ID] [--revert] [--dry-run|--apply] <path>
```

Backup runs apply by default. Revert runs `--dry-run` by default; use `--apply` to overwrite.

Examples:

```sh
bak --apply ~/.config/app.conf
bak --list ~/.config/app.conf
bak --revert --apply ~/.config/app.conf
bak --revert --version 20260224T120501Z --apply ~/.config/app.conf
bak --apply --exclude "*.bin" --exclude "*.png" ~/data
```

## Storage Layout

Default root is `~/.bak` unless overridden by `--root`.

Each target gets a directory:

```
~/.bak/<escaped_source_path>/<version_id>/
```

Each version contains:

- `data.tar`
- `manifest.txt`

The manifest includes absolute paths for source, backup root, version directory, and archive, plus `sha256` hashes for each file in the backup.

## Notes

- Exclude patterns are matched by `tar` against paths inside the backup.
- Restore overwrites existing files but does not delete extra files in directories.
- Patterns are shell globs; avoid spaces in patterns.
