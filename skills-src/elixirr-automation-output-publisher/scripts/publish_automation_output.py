#!/usr/bin/env python3

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Copy processed automation output files into an Elixirr outputs/automations directory."
    )
    parser.add_argument("--source-dir", required=True, help="Directory containing staged automation output files.")
    parser.add_argument("--dest-dir", required=True, help="Destination directory for published files.")
    parser.add_argument(
        "--pattern",
        required=True,
        help="Glob pattern used to match source files, for example 'daily-bug-scan-*.md'.",
    )
    parser.add_argument(
        "--copy-all",
        action="store_true",
        help="Copy all matching files instead of only the latest one.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite destination files when the same filename already exists.",
    )
    return parser.parse_args()


def find_matches(source_dir: Path, pattern: str) -> list[Path]:
    matches = [path for path in source_dir.glob(pattern) if path.is_file()]
    return sorted(matches, key=lambda path: (path.stat().st_mtime, path.name))


def copy_one(source_file: Path, dest_dir: Path, overwrite: bool) -> str:
    dest_file = dest_dir / source_file.name
    if dest_file.exists() and not overwrite:
        return f"skipped existing {dest_file}"

    shutil.copy2(source_file, dest_file)
    action = "overwrote" if dest_file.exists() and overwrite else "copied"
    return f"{action} {source_file} -> {dest_file}"


def main() -> int:
    args = parse_args()
    source_dir = Path(args.source_dir).expanduser().resolve()
    dest_dir = Path(args.dest_dir).expanduser().resolve()

    if not source_dir.is_dir():
        print(f"source directory does not exist: {source_dir}", file=sys.stderr)
        return 1

    matches = find_matches(source_dir, args.pattern)
    if not matches:
        print(f"no files matched pattern {args.pattern!r} in {source_dir}")
        return 0

    dest_dir.mkdir(parents=True, exist_ok=True)

    selected = matches if args.copy_all else [matches[-1]]
    results = [copy_one(path, dest_dir, args.overwrite) for path in selected]

    print(f"source: {source_dir}")
    print(f"destination: {dest_dir}")
    print(f"pattern: {args.pattern}")
    for line in results:
        print(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
