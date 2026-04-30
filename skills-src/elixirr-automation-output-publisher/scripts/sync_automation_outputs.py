#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
PUBLISHER_PATH = SCRIPT_DIR / "publish_automation_output.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sync project automation outputs into Elixirr client output folders."
    )
    parser.add_argument(
        "--config",
        help="Optional path to a JSON config file containing sync mappings.",
    )
    parser.add_argument(
        "--mapping",
        dest="mappings",
        action="append",
        nargs=3,
        metavar=("NAME", "SOURCE", "DESTINATION"),
        help="Inline mapping to sync. Repeat this flag for multiple mappings.",
    )
    parser.add_argument(
        "--pattern",
        default="*.md",
        help="Glob pattern to match within each source automation directory.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the publish commands without copying files.",
    )
    parser.add_argument(
        "--latest-only",
        action="store_true",
        help="Copy only the latest matching file per source instead of all matches.",
    )
    return parser.parse_args()


def load_config(config_path: Path) -> list[dict[str, str]]:
    raw = json.loads(config_path.read_text())
    mappings = raw.get("mappings", [])
    if not isinstance(mappings, list) or not mappings:
        raise ValueError(f"no mappings found in {config_path}")
    return mappings


def build_inline_mappings(raw_mappings: list[list[str]] | None) -> list[dict[str, str]]:
    mappings: list[dict[str, str]] = []
    for raw_mapping in raw_mappings or []:
        name, source, destination = raw_mapping
        mappings.append(
            {
                "name": name,
                "source": source,
                "destination": destination,
            }
        )
    return mappings


def build_command(mapping: dict[str, str], pattern: str, latest_only: bool) -> list[str]:
    command = [
        sys.executable,
        str(PUBLISHER_PATH),
        "--source-dir",
        mapping["source"],
        "--dest-dir",
        mapping["destination"],
        "--pattern",
        pattern,
    ]
    if not latest_only:
        command.append("--copy-all")
    return command


def validate_mapping(mapping: dict[str, str]) -> None:
    for field in ("name", "source", "destination"):
        if field not in mapping or not mapping[field]:
            raise ValueError(f"mapping is missing required field {field!r}: {mapping}")


def resolve_mappings(args: argparse.Namespace) -> list[dict[str, str]]:
    mappings: list[dict[str, str]] = []

    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.is_file():
            raise FileNotFoundError(f"config file does not exist: {config_path}")
        mappings.extend(load_config(config_path))

    mappings.extend(build_inline_mappings(args.mappings))

    if not mappings:
        raise ValueError("provide at least one --mapping or a --config file")

    return mappings


def main() -> int:
    args = parse_args()

    if not PUBLISHER_PATH.is_file():
        print(f"publisher script does not exist: {PUBLISHER_PATH}", file=sys.stderr)
        return 1

    try:
        mappings = resolve_mappings(args)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"failed to resolve mappings: {exc}", file=sys.stderr)
        return 1

    exit_code = 0
    for mapping in mappings:
        try:
            validate_mapping(mapping)
        except ValueError as exc:
            print(exc, file=sys.stderr)
            exit_code = 1
            continue

        command = build_command(mapping, args.pattern, args.latest_only)

        print(f"[{mapping['name']}]")
        if args.dry_run:
            print(" ".join(command))
            continue

        result = subprocess.run(command, text=True, capture_output=True)
        if result.stdout:
            print(result.stdout.rstrip())
        if result.returncode != 0:
            exit_code = result.returncode
            if result.stderr:
                print(result.stderr.rstrip(), file=sys.stderr)

    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
