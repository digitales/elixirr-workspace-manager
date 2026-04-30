#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
import shutil
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Iterable


STOPWORDS = {
    "the",
    "and",
    "for",
    "that",
    "have",
    "with",
    "this",
    "from",
    "they",
    "will",
    "would",
    "what",
    "when",
    "where",
    "which",
    "there",
    "about",
    "please",
    "thanks",
    "thank",
    "into",
    "just",
    "need",
    "also",
    "still",
    "been",
    "your",
    "their",
    "them",
    "were",
    "should",
    "could",
    "today",
    "tomorrow",
    "yesterday",
    "week",
    "next",
    "client",
    "channel",
    "project",
    "slack",
    "teams",
    "team",
    "going",
    "want",
    "make",
    "made",
    "time",
    "then",
    "than",
    "http",
    "https",
    "www",
    "com",
}

ACTION_PATTERNS = [
    re.compile(r"\bplease\b", re.I),
    re.compile(r"\bcan you\b", re.I),
    re.compile(r"\bneed to\b", re.I),
    re.compile(r"\bwe need\b", re.I),
    re.compile(r"\bmust\b", re.I),
    re.compile(r"\bshould\b", re.I),
    re.compile(r"\basap\b", re.I),
    re.compile(r"\bby [A-Z][a-z]+", re.I),
    re.compile(r"\bno later than\b", re.I),
]

RISK_PATTERNS = [
    re.compile(r"\bblock", re.I),
    re.compile(r"\brisk", re.I),
    re.compile(r"\bissue\b", re.I),
    re.compile(r"\bproblem\b", re.I),
    re.compile(r"\bnot working\b", re.I),
    re.compile(r"\bdelay\b", re.I),
    re.compile(r"\bconfus", re.I),
    re.compile(r"\bunsure\b", re.I),
]

DECISION_PATTERNS = [
    re.compile(r"\bdecid", re.I),
    re.compile(r"\bwe('?| )ll\b", re.I),
    re.compile(r"\bgoing to\b", re.I),
    re.compile(r"\bkeep\b", re.I),
    re.compile(r"\bremove\b", re.I),
    re.compile(r"\bshow\b", re.I),
]

REQUEST_PATTERNS = [
    re.compile(r"\bcan everyone\b", re.I),
    re.compile(r"\bcan we\b", re.I),
    re.compile(r"\bplease\b", re.I),
    re.compile(r"\bdo you know\b", re.I),
    re.compile(r"\bconfirm\b", re.I),
]

DATE_PREFIX = re.compile(r"(\d{4}-\d{2}-\d{2})")


class Message:
    def __init__(self, author: str, text: str) -> None:
        self.author = author
        self.text = text


def strip_noise(text: str) -> str:
    text = text.replace("\xa0", " ")
    text = re.sub(r"<([^>|]+)\|([^>]+)>", r"\2 (\1)", text)
    text = re.sub(r"<@[^>]+>", "@user", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def clip(text: str, limit: int = 220) -> str:
    text = strip_noise(text)
    if len(text) <= limit:
        return text
    return text[: limit - 1].rstrip() + "…"


def parse_json_messages(path: Path) -> list[Message]:
    data = json.loads(path.read_text())
    messages: list[Message] = []
    if not isinstance(data, list):
        return messages
    for item in data:
        if not isinstance(item, dict) or item.get("type") != "message":
            continue
        text = strip_noise(str(item.get("text") or ""))
        if not text:
            continue
        profile = item.get("user_profile") or {}
        author = (
            profile.get("real_name")
            or profile.get("display_name")
            or profile.get("first_name")
            or str(item.get("user") or "Unknown")
        )
        messages.append(Message(author=author, text=text))
    return messages


def parse_markdown_messages(path: Path) -> list[Message]:
    lines = path.read_text().splitlines()
    messages: list[Message] = []
    current_author = "Unknown"
    buffer: list[str] = []
    author_line = re.compile(r"^(.+?)\s+\[\d{1,2}:\d{2}\s+[AP]M\]$")

    def flush() -> None:
        nonlocal buffer
        joined = strip_noise(" ".join(buffer))
        if joined:
            messages.append(Message(author=current_author, text=joined))
        buffer = []

    for raw_line in lines:
        line = raw_line.strip()
        if not line:
            continue
        match = author_line.match(line)
        if match:
            flush()
            current_author = strip_noise(match.group(1))
            continue
        if re.match(r"^\[\d{1,2}:\d{2}\s+[AP]M\]", line):
            continue
        buffer.append(line)
    flush()
    return messages


def extract_messages(path: Path) -> list[Message]:
    if path.suffix.lower() == ".json":
        return parse_json_messages(path)
    return parse_markdown_messages(path)


def infer_channel(path: Path, platform_dir: Path) -> str:
    rel = path.relative_to(platform_dir)
    if len(rel.parts) > 1:
        return rel.parts[0]
    stem = path.stem
    match = DATE_PREFIX.match(stem)
    if match:
        remainder = stem[len(match.group(1)) :].strip("-_ ")
        if remainder:
            return remainder
    return "general"


def infer_date_string(path: Path) -> str:
    match = DATE_PREFIX.match(path.stem)
    if match:
        return match.group(1)
    return datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d")


def classify_lines(messages: Iterable[Message], patterns: list[re.Pattern[str]], limit: int = 5) -> list[str]:
    results: list[str] = []
    seen: set[str] = set()
    for msg in messages:
        if any(pattern.search(msg.text) for pattern in patterns):
            line = f"{msg.author}: {clip(msg.text)}"
            if line not in seen:
                seen.add(line)
                results.append(line)
        if len(results) >= limit:
            break
    return results


def extract_topics(messages: Iterable[Message], limit: int = 5) -> list[str]:
    tokens: Counter[str] = Counter()
    jira_keys: list[str] = []
    for msg in messages:
        jira_keys.extend(re.findall(r"\b[A-Z][A-Z0-9]+-\d+\b", msg.text))
        for token in re.findall(r"[A-Za-z][A-Za-z0-9_-]{3,}", msg.text.lower()):
            if token in STOPWORDS or token.startswith("http"):
                continue
            tokens[token] += 1

    topics = [key for key, _ in Counter(jira_keys).most_common(limit)]
    for token, _ in tokens.most_common(limit * 2):
        if token not in topics:
            topics.append(token)
        if len(topics) >= limit:
            break
    return topics[:limit]


def build_summary(messages: list[Message]) -> list[str]:
    if not messages:
        return ["No usable message text was extracted from this export."]

    participants = [msg.author for msg in messages if msg.author]
    top_people = ", ".join(name for name, _ in Counter(participants).most_common(4))
    topics = extract_topics(messages)
    summary = [
        f"This export contains {len(messages)} messages from {len(set(participants))} participants.",
        f"Most active participants: {top_people or 'Unknown'}.",
    ]
    if topics:
        summary.append(f"Likely discussion themes: {', '.join(topics)}.")

    substantial = [msg for msg in messages if len(msg.text) > 60]
    if substantial:
        summary.append(f"Notable message: {substantial[0].author}: {clip(substantial[0].text)}")
    return summary


def render_output(
    *,
    client: str,
    project: str,
    platform: str,
    channel: str,
    date_str: str,
    source_file: Path,
    messages: list[Message],
) -> str:
    summary_lines = build_summary(messages)
    key_signals = classify_lines(messages, ACTION_PATTERNS + RISK_PATTERNS + DECISION_PATTERNS, limit=6)
    risks = classify_lines(messages, RISK_PATTERNS, limit=5)
    decisions = classify_lines(messages, DECISION_PATTERNS, limit=5)
    actions = classify_lines(messages, ACTION_PATTERNS, limit=5)
    requests = classify_lines(messages, REQUEST_PATTERNS, limit=5)

    lines = [
        "# Communication Summary",
        "",
        f"Client: {client}",
        f"Project: {project}",
        f"Platform: {platform}",
        f"Channel: {channel}",
        f"Date: {date_str}",
        f"Source File: {source_file}",
        "",
        "## Summary",
        "",
    ]
    lines.extend(f"- {line}" for line in summary_lines)
    lines.extend(["", "## Key Signals", ""])
    lines.extend(f"- {line}" for line in (key_signals or ["No clear signals were auto-detected."]))
    lines.extend(["", "## Risks / Blockers", ""])
    lines.extend(f"- {line}" for line in (risks or ["No explicit risks or blockers were auto-detected."]))
    lines.extend(["", "## Decisions", ""])
    lines.extend(f"- {line}" for line in (decisions or ["No explicit decisions were auto-detected."]))
    lines.extend(["", "## Actions", ""])
    lines.extend(f"- {line}" for line in (actions or ["No explicit actions were auto-detected."]))
    lines.extend(["", "## Stakeholder Requests", ""])
    lines.extend(f"- {line}" for line in (requests or ["No stakeholder requests were auto-detected."]))
    lines.extend(["", "## Notes", ""])
    lines.append("- This summary was generated automatically from the raw export and should be treated as a first-pass normalization.")
    return "\n".join(lines) + "\n"


def archive_file(path: Path) -> None:
    archive_dir = path.parent / "archive"
    archive_dir.mkdir(parents=True, exist_ok=True)
    target = archive_dir / path.name
    if target.exists():
        stem = path.stem
        suffix = path.suffix
        counter = 1
        while True:
            candidate = archive_dir / f"{stem}-{counter}{suffix}"
            if not candidate.exists():
                target = candidate
                break
            counter += 1
    shutil.move(str(path), str(target))


def process_file(path: Path) -> tuple[Path, Path]:
    client_dir = path
    while client_dir.parent.name != "clients":
        client_dir = client_dir.parent
    client = client_dir.name

    if "projects" in path.parts:
        project = path.parts[path.parts.index("projects") + 1]
        platform = path.parts[path.parts.index("manual-exports") + 1]
        platform_dir = client_dir / "projects" / project / "manual-exports" / platform
        output_root = client_dir / "projects" / project / "outputs" / platform
    else:
        project = "-"
        platform = path.parts[path.parts.index("manual-exports") + 1]
        platform_dir = client_dir / "manual-exports" / platform
        output_root = client_dir / "outputs" / platform

    channel = infer_channel(path, platform_dir)
    if channel == "general" and project == "-":
        channel = client
    date_str = infer_date_string(path)
    output_dir = output_root / channel
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{date_str}.md"

    rendered = render_output(
        client=client,
        project=project,
        platform=platform,
        channel=channel,
        date_str=date_str,
        source_file=path,
        messages=extract_messages(path),
    )
    output_path.write_text(rendered)
    archive_file(path)
    return output_path, path


def iter_source_files(root: Path) -> list[Path]:
    results: list[Path] = []
    for path in root.glob("clients/**/manual-exports/**/*"):
        if not path.is_file():
            continue
        if path.name == ".DS_Store":
            continue
        if "archive" in path.parts:
            continue
        if path.suffix.lower() not in {".json", ".md", ".txt"}:
            continue
        results.append(path)
    return sorted(results)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Normalize Elixirr Slack and Teams manual exports.")
    parser.add_argument(
        "--root",
        default="~/Documents/elixirr",
        help="Elixirr workspace root containing the clients directory.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    workspace_root = Path(args.root).expanduser()
    files = iter_source_files(workspace_root)
    processed = 0
    for path in files:
        output_path, source_path = process_file(path)
        processed += 1
        print(f"processed\t{source_path}\t{output_path}")
    print(f"total\t{processed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
