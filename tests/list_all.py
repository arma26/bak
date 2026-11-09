#!/usr/bin/env python3
"""Read-only inventory regression tests; retain scratch fixtures for inspection."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

BAK = Path(__file__).resolve().parents[1] / "bak"


class ListAllTests(unittest.TestCase):
    def test_inventory(self):
        scratch = Path(tempfile.mkdtemp(prefix="bak-list-", dir=os.environ["TMPDIR"])).resolve()
        root = scratch / "backups"

        def run(*args, **kwargs):
            return subprocess.run([str(BAK), "--root", str(root), *map(str, args)],
                                  text=True, capture_output=True, **kwargs)

        self.assertEqual(run("--list").stdout, "VERSION\tFILENAME\tDIRECTORY\n")
        self.assertFalse(root.exists())
        paths = [scratch / "first dir" / "app.conf", scratch / "other" / "app.conf"]
        expected = []
        for path, count in zip(paths, [2, 1]):
            path.parent.mkdir()
            path.write_text("config\n")
            for _ in range(count):
                result = run(path)
                self.assertEqual(result.returncode, 0, result.stderr)
            versions = run("--list", path)
            self.assertEqual(versions.returncode, 0, versions.stderr)
            for version in versions.stdout.splitlines():
                expected.append(f"{version}\t{path.name}\t{path.parent}")
        before = {str(p): p.read_bytes() for p in root.rglob("*") if p.is_file()}
        result = run("--list")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines()[0], "VERSION\tFILENAME\tDIRECTORY")
        self.assertCountEqual(result.stdout.splitlines()[1:], expected)
        self.assertEqual(before, {str(p): p.read_bytes() for p in root.rglob("*") if p.is_file()})
        # Inventory must not resolve or require the original source directory.
        manifest = next(root.glob("*/*/manifest.txt"))
        content = manifest.read_text()
        source = content.splitlines()[0].removeprefix("SOURCE_ABS=")
        manifest.write_text(content.replace("SOURCE_ABS=" + source + "\n",
                                            "SOURCE_ABS=/missing/config dir/app.conf\n", 1))
        self.assertIn("\tapp.conf\t/missing/config dir\n", run("--list").stdout)
        self.assertNotEqual(run("--list", "--revert").returncode, 0)
        self.assertNotEqual(run("--list", "--diff").returncode, 0)
        self.assertNotEqual(run().returncode, 0)


if __name__ == "__main__":
    unittest.main()
