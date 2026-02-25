#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
cd "$ROOT_DIR"

tmp="$(mktemp -d -t bak-readme.XXXXXX)"
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

# README quickstart commands (kept literal):
cp ./bak "$tmp/bak"
chmod +x "$tmp/bak"
PATH="$tmp:$PATH"

work="$tmp/work"
root="$tmp/backups"
mkdir -p "$work"

printf 'one\n' > "$work/app.conf"
bak --root "$root" "$work/app.conf"

version1="$(bak --root "$root" --list "$work/app.conf" | head -n 1)"
[ -n "$version1" ] || { echo "missing version1" >&2; exit 1; }
bak --root "$root" --list "$work/app.conf" >/dev/null

printf 'two\n' > "$work/app.conf"
bak --root "$root" --revert "$work/app.conf"
[ "$(cat "$work/app.conf")" = "two" ] || { echo "dry-run revert changed file" >&2; exit 1; }

bak --root "$root" --revert --apply "$work/app.conf"
[ "$(cat "$work/app.conf")" = "one" ] || { echo "apply revert failed" >&2; exit 1; }

printf 'three\n' > "$work/app.conf"
bak --root "$root" "$work/app.conf"
version2="$(bak --root "$root" --list "$work/app.conf" | head -n 1)"
[ -n "$version2" ] || { echo "missing version2" >&2; exit 1; }
[ "$version2" != "$version1" ] || { echo "expected distinct versions" >&2; exit 1; }

printf 'four\n' > "$work/app.conf"
bak --root "$root" --revert --version "$version1" --apply "$work/app.conf"
[ "$(cat "$work/app.conf")" = "one" ] || { echo "versioned revert failed" >&2; exit 1; }

mkdir -p "$work/dir/sub"
printf 'alpha\n' > "$work/dir/sub/a.txt"
printf '\x00\x01\x02' > "$work/dir/sub/b.bin"
bak --root "$root" --exclude "*.bin" "$work/dir"

bak --root "$root" --diff "$work/app.conf" >/dev/null 2>&1 && { echo "expected diff" >&2; exit 1; }

echo "ok"
