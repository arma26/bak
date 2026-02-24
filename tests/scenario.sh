#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
BAK_BIN="$ROOT_DIR/bak"

fail() {
  echo "test failure: $*" >&2
  exit 1
}

tmp="$(mktemp -d -t bak-test.XXXXXX)"
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

backup_root="$tmp/backup-root"
work="$tmp/work"
mkdir -p "$work"

file="$work/sample.txt"
printf 'one\n' > "$file"

if [ ! -x "$BAK_BIN" ]; then
  fail "expected executable at $BAK_BIN"
fi

echo "scenario: file backup and revert"
"$BAK_BIN" --root "$backup_root" "$file"
version="$("$BAK_BIN" --root "$backup_root" --list "$file" | head -n 1)"
[ -n "$version" ] || fail "expected a version id"

printf 'two\n' > "$file"
"$BAK_BIN" --root "$backup_root" --revert "$file"
content="$(cat "$file")"
[ "$content" = "two" ] || fail "expected dry-run revert to keep content"

"$BAK_BIN" --root "$backup_root" --apply --revert "$file"
content="$(cat "$file")"
[ "$content" = "one" ] || fail "expected reverted content to be 'one'"

echo "scenario: version selection"
printf 'three\n' > "$file"
"$BAK_BIN" --root "$backup_root" "$file"
old_version="$version"
new_version="$("$BAK_BIN" --root "$backup_root" --list "$file" | head -n 1)"
[ "$new_version" != "$old_version" ] || fail "expected new version to differ"
latest_content="three"

printf 'four\n' > "$file"
"$BAK_BIN" --root "$backup_root" --apply --revert --version "$old_version" "$file"
content="$(cat "$file")"
[ "$content" = "one" ] || fail "expected revert to old version to restore 'one'"

echo "scenario: directory backup with exclude"
dir="$work/dir"
mkdir -p "$dir/sub"
printf 'alpha\n' > "$dir/sub/a.txt"
printf '\x00\x01\x02' > "$dir/sub/b.bin"
"$BAK_BIN" --root "$backup_root" --exclude "*.bin" "$dir"
dir_abs="$(cd "$dir" && pwd -P)"
dir_key="$(printf '%s' "$dir_abs" | sed 's|/|__|g')"
version_id="$("$BAK_BIN" --root "$backup_root" --list "$dir" | head -n 1)"
version_dir="$backup_root/$dir_key/$version_id"
manifest="$version_dir/manifest.txt"
[ -f "$manifest" ] || fail "expected manifest at $manifest"
if grep -q "b.bin" "$manifest"; then
  fail "expected excluded binary not to appear in manifest"
fi

echo "scenario: diff file"
printf 'diff\n' > "$file"
"$BAK_BIN" --root "$backup_root" --diff "$file" >/dev/null 2>&1 && fail "expected diff to detect changes"
printf '%s\n' "$latest_content" > "$file"
"$BAK_BIN" --root "$backup_root" --diff "$file" >/dev/null 2>&1 || fail "expected diff to report no changes"

echo "scenario: diff directory"
printf 'beta\n' > "$dir/sub/a.txt"
"$BAK_BIN" --root "$backup_root" --diff "$dir" >/dev/null 2>&1 && fail "expected directory diff to detect changes"
printf 'alpha\n' > "$dir/sub/a.txt"
mv "$dir/sub/b.bin" "$tmp/b.bin"
"$BAK_BIN" --root "$backup_root" --diff "$dir" >/dev/null 2>&1 || fail "expected directory diff to report no changes"

echo "ok"
