# bak

Versioned backups for files and directories with fast restore.

## Install

Place `bak` on your `PATH`:

```sh
cp ./bak /usr/local/bin/bak
chmod +x /usr/local/bin/bak
```

## Usage

```sh
bak [--root PATH] [--exclude GLOB ...] [--list] [--version ID] [--revert] [--diff] [--dry-run|--apply] <path>
bak --diff [--version ID] [--root PATH] <path> [path ...]
```

Defaults:

- Backup runs apply by default.
- Revert runs `--dry-run` by default. Use `--apply` to overwrite.
- `--diff` is read-only and ignores `--dry-run` / `--apply`.

## Quickstart

Run these commands literally to exercise backup, list, dry-run revert, apply revert, version selection, directory excludes, and diff.

```sh
tmp="$(mktemp -d)"
cp ./bak "$tmp/bak"
chmod +x "$tmp/bak"
PATH="$tmp:$PATH"

work="$tmp/work"
root="$tmp/backups"
mkdir -p "$work"

printf 'one\n' > "$work/app.conf"
bak --root "$root" "$work/app.conf"

version1="$(bak --root "$root" --list "$work/app.conf" | head -n 1)"
bak --root "$root" --list "$work/app.conf"

printf 'two\n' > "$work/app.conf"
bak --root "$root" --revert "$work/app.conf"
cat "$work/app.conf"

bak --root "$root" --revert --apply "$work/app.conf"
cat "$work/app.conf"

printf 'three\n' > "$work/app.conf"
bak --root "$root" "$work/app.conf"
version2="$(bak --root "$root" --list "$work/app.conf" | head -n 1)"

printf 'four\n' > "$work/app.conf"
bak --root "$root" --revert --version "$version1" --apply "$work/app.conf"
cat "$work/app.conf"

mkdir -p "$work/dir/sub"
printf 'alpha\n' > "$work/dir/sub/a.txt"
printf '\x00\x01\x02' > "$work/dir/sub/b.bin"
bak --root "$root" --exclude "*.bin" "$work/dir"

bak --root "$root" --diff "$work/app.conf"
```

## Storage Layout

Default root is `~/.bak` unless overridden by `--root`.

Each target gets a directory:

```text
~/.bak/<key>/<version_id>/
```

Each version contains:

- `<key>.tar`
- `manifest.txt`

`manifest.txt` includes absolute paths for source, backup root, version directory, and archive, plus `sha256` values for included files.

Key scheme:

```text
parent = absolute parent directory path
base = basename of target path
key = base64url(parent) + "_" + base
```

## Notes

- Exclude patterns are passed to `tar --exclude` for backup creation.
- Revert overwrites existing destination files and does not delete extra files.
- `--diff` supports multiple paths.
- This project is best-effort cross-platform and primarily exercised on macOS-style userland.
