#!/usr/bin/env python3

"""Batch-write Elixirr working-memory bootstrap files from drafted content."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Write client-level or project-level working-memory/current.md files "
            "from a JSON spec of already-drafted bootstrap content."
        )
    )
    parser.add_argument(
        "--workspace-root",
        required=True,
        help="Path to the Elixirr workspace root that contains the clients directory.",
    )
    parser.add_argument(
        "--input",
        required=True,
        help=(
            "Path to a JSON file containing bootstrap content. "
            "Keys are workspace-relative target paths and values are markdown strings."
        ),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print target files without writing them.",
    )
    return parser.parse_args()


def load_spec(path: Path) -> dict[str, str]:
    data = json.loads(path.read_text())
    if not isinstance(data, dict) or not all(
        isinstance(key, str) and isinstance(value, str) for key, value in data.items()
    ):
        raise ValueError(
            "Input JSON must be an object mapping relative file paths to markdown strings."
        )
    return data


def resolve_target(workspace_root: Path, relative_path: str) -> Path:
    target = (workspace_root / relative_path).resolve()
    workspace_root = workspace_root.resolve()
    if workspace_root not in target.parents and target != workspace_root:
        raise ValueError(f"Refusing to write outside workspace root: {relative_path}")
    if target.name != "current.md":
        raise ValueError(f"Target must end with current.md: {relative_path}")
    return target


def main() -> None:
    args = parse_args()
    workspace_root = Path(args.workspace_root)
    spec = load_spec(Path(args.input))

    for relative_path, content in spec.items():
        target = resolve_target(workspace_root, relative_path)
        print(target)
        if args.dry_run:
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content.rstrip() + "\n")


if __name__ == "__main__":
    main()
