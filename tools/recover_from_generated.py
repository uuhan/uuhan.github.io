#!/usr/bin/env python3
"""Recover Markdown posts from the generated uuhan.github.io HTML output."""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from html import unescape
from pathlib import Path


@dataclass
class Post:
    source: Path
    slug: str
    date: str
    title: str
    tags: list[str]
    body_html: str


MONTHS = {
    "January": "01",
    "February": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12",
}


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: recover_from_generated.py GENERATED_SITE OUT_POST_DIR", file=sys.stderr)
        return 2
    site = Path(sys.argv[1]).resolve()
    out_dir = Path(sys.argv[2]).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    for html_path in sorted((site / "2017").glob("*/*/*.html")):
        post = parse_post(html_path)
        write_post(post, out_dir)
    return 0


def parse_post(path: Path) -> Post:
    html = path.read_text(encoding="utf-8")
    content = re.search(
        r'<div class="hyphenate" id="content">(.*?)\n</div>\n<div id="footer">',
        html,
        re.S,
    )
    if not content:
        raise RuntimeError(f"content not found in {path}")
    content_html = content.group(1)
    title = text_of_first(r"<h1>(.*?)</h1>", content_html)
    posted = text_of_first(r"Posted on\s+([^<\n]+)", content_html)
    date = parse_date(posted)
    tag_html = re.search(r"分类:\s*(.*?)\n\s*</div>", content_html, re.S)
    tags = re.findall(r">([^<>]+)</a>", tag_html.group(1) if tag_html else "")
    body = re.sub(r"^\s*<h1>.*?</h1>", "", content_html, flags=re.S)
    body = re.sub(r"\s*<div class=\"info\">.*?</div>", "", body, flags=re.S)
    body = re.sub(r"\s*<div id=\"toc\">.*?</div>", "", body, flags=re.S)
    slug = path.stem
    return Post(path, slug, date, title, tags, body.strip())


def text_of_first(pattern: str, html: str) -> str:
    match = re.search(pattern, html, re.S)
    if not match:
        raise RuntimeError(f"pattern not found: {pattern}")
    return re.sub(r"\s+", " ", unescape(match.group(1))).strip()


def parse_date(text: str) -> str:
    month, day, year = text.replace(",", "").split()
    return f"{year}-{MONTHS[month]}-{int(day):02d}"


def write_post(post: Post, out_dir: Path) -> None:
    markdown = html_to_markdown(post.body_html)
    front_matter = [
        "---",
        f"title: {post.title}",
        f"date: {post.date}",
        f"tags: {', '.join(post.tags)}",
        "---",
        "",
    ]
    path = out_dir / f"{post.date}-{post.slug}.md"
    path.write_text("\n".join(front_matter) + markdown.strip() + "\n", encoding="utf-8")


def html_to_markdown(fragment: str) -> str:
    with tempfile.NamedTemporaryFile("w", suffix=".html", encoding="utf-8", delete=False) as tmp:
        tmp.write(fragment)
        tmp_path = Path(tmp.name)
    try:
        proc = subprocess.run(
            [
                "pandoc",
                "--from=html-native_divs-native_spans",
                "--to=gfm+footnotes",
                "--wrap=none",
                str(tmp_path),
            ],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
        )
        return proc.stdout
    finally:
        tmp_path.unlink(missing_ok=True)


if __name__ == "__main__":
    raise SystemExit(main())

