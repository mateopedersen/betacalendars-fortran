#!/usr/bin/env python3
"""Check local FORD links and fragments, or crawl a deployed FORD site."""

from __future__ import annotations

import argparse
from collections import deque
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import unquote, urldefrag, urljoin, urlsplit
from urllib.request import Request, urlopen


class PageLinks(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.links: list[tuple[str, str]] = []
        self.anchors: set[str] = set()

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if tag == "a" and values.get("href") is not None:
            self.links.append((values["href"] or "", values.get("id") or ""))
        if values.get("id"):
            self.anchors.add(values["id"] or "")
        if tag == "a" and values.get("name"):
            self.anchors.add(values["name"] or "")


def parse_html(content: bytes) -> PageLinks:
    parser = PageLinks()
    parser.feed(content.decode("utf-8", errors="replace"))
    return parser


def ignored_scheme(url: str) -> bool:
    return urlsplit(url).scheme.lower() in {"mailto", "tel", "javascript", "data"}


def fetch(url: str) -> tuple[int, str, bytes]:
    request = Request(url, headers={"User-Agent": "betacalendars-ford-link-check/1.0"})
    try:
        with urlopen(request, timeout=20) as response:
            return response.status, response.geturl(), response.read()
    except HTTPError as error:
        return error.code, error.geturl(), error.read()
    except (URLError, TimeoutError) as error:
        return 0, url, str(error).encode()


def crawl_remote(start_url: str) -> int:
    start_url = start_url.rstrip("/") + "/"
    start = urlsplit(start_url)
    base_path = start.path.rstrip("/") + "/"
    queue = deque([start_url])
    seen: set[str] = set()
    parsed: dict[str, PageLinks] = {}
    errors: list[str] = []
    checked = 0

    while queue:
        page_url = queue.popleft()
        page_url, _ = urldefrag(page_url)
        if page_url in seen:
            continue
        seen.add(page_url)
        status, final_url, body = fetch(page_url)
        checked += 1
        if status < 200 or status >= 400:
            errors.append(f"HTTP {status or 'ERROR'} {page_url}")
            continue
        final = urlsplit(final_url)
        if final.netloc != start.netloc or not final.path.startswith(base_path):
            errors.append(f"redirect escaped docs base: {page_url} -> {final_url}")
            continue
        document = parse_html(body)
        parsed[final_url] = document

        for href, _ in document.links:
            if not href or ignored_scheme(href):
                continue
            target = urljoin(final_url, href)
            target_parts = urlsplit(target)
            if target_parts.netloc != start.netloc:
                continue
            if not target_parts.path.startswith(base_path):
                errors.append(f"outside docs base: {final_url} -> {target}")
                continue
            target_page = urldefrag(target)[0]
            if target_page not in seen:
                queue.append(target_page)

    for page_url, document in parsed.items():
        for href, _ in document.links:
            if not href or ignored_scheme(href):
                continue
            target = urljoin(page_url, href)
            parts = urlsplit(target)
            if parts.netloc != start.netloc:
                continue
            if not parts.path.startswith(base_path):
                continue
            target_page = urldefrag(target)[0]
            if not parts.fragment:
                continue
            target_doc = parsed.get(target_page)
            if target_doc is None:
                # A trailing slash and its index file represent the same page.
                index_url = target_page.rstrip("/") + "/index.html"
                target_doc = parsed.get(index_url)
            if target_doc is None or unquote(parts.fragment) not in target_doc.anchors:
                errors.append(f"broken anchor {target}")

    print(f"Pages fetched: {len(seen)}")
    print(f"Internal links checked: {sum(len(doc.links) for doc in parsed.values())}")
    print(f"Broken links: {len(errors)}")
    for error in errors:
        print(error)
    return 1 if errors else 0


def local_target(root: Path, page: Path, href: str, base_url: str) -> tuple[Path | None, str]:
    target_url = urljoin(base_url, href) if urlsplit(href).scheme or href.startswith("//") else href
    parts = urlsplit(target_url)
    base = urlsplit(base_url)
    if parts.scheme and not parts.netloc:
        return root / "__malformed_url__", parts.fragment
    if parts.scheme and (parts.scheme, parts.netloc) != (base.scheme, base.netloc):
        return None, parts.fragment
    base_path = base.path.rstrip("/") + "/"
    if parts.scheme and not parts.path.startswith(base_path):
        return root / "__outside_docs_base__", parts.fragment
    if parts.scheme:
        relative = unquote(parts.path[len(base_path) :])
    else:
        relative = unquote(parts.path)
    if not parts.path:
        target = page
    elif not relative:
        target = root / "index.html"
    else:
        candidate = Path(relative)
        target = candidate if candidate.is_absolute() else (page.parent / candidate)
        if target.is_dir() or str(parts.path).endswith("/"):
            target = target / "index.html"
        elif not target.suffix:
            if target.with_suffix(".html").exists():
                target = target.with_suffix(".html")
            else:
                target = target / "index.html"
    try:
        target.resolve().relative_to(root.resolve())
    except ValueError:
        return root / "__outside_docs_base__", parts.fragment
    return target, parts.fragment


def check_local(directory: Path, base_url: str) -> int:
    root = directory.resolve()
    pages = sorted(root.rglob("*.html"))
    documents = {page: parse_html(page.read_bytes()) for page in pages}
    errors: list[str] = []
    checked = 0
    module_links = 0
    procedure_type_links = 0
    anchors_checked = 0
    base = urlsplit(base_url)

    for page, document in documents.items():
        for href, _ in document.links:
            if not href or ignored_scheme(href):
                continue
            parts = urlsplit(href)
            if parts.scheme and (parts.scheme, parts.netloc) != (base.scheme, base.netloc):
                continue
            target, fragment = local_target(root, page, href, base_url)
            checked += 1
            if target is None:
                continue
            if not target.is_file():
                errors.append(f"missing local target {href} from {page.relative_to(root)}")
                continue
            target_parts = target.relative_to(root).parts
            if target_parts and target_parts[0] == "module":
                module_links += 1
            elif target_parts and target_parts[0] in {"proc", "type"}:
                procedure_type_links += 1
            if fragment:
                anchors_checked += 1
                target_doc = documents.get(target)
                if target_doc is None:
                    target_doc = parse_html(target.read_bytes()) if target.suffix == ".html" else None
                if target_doc is None or unquote(fragment) not in target_doc.anchors:
                    errors.append(f"broken anchor {href} from {page.relative_to(root)}")

    print(f"HTML pages: {len(pages)}")
    print(f"Internal links checked: {checked}")
    print(f"Module page links checked: {module_links}")
    print(f"Procedure/type links checked: {procedure_type_links}")
    print(f"Anchors checked: {anchors_checked}")
    print(f"Broken links: {len(errors)}")
    for error in errors:
        print(error)
    return 1 if errors else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", help="generated HTML directory or live documentation URL")
    parser.add_argument("--base-url", default="https://mateopedersen.github.io/betacalendars-fortran/")
    args = parser.parse_args()
    if args.target.startswith(("https://", "http://")):
        return crawl_remote(args.target)
    return check_local(Path(args.target), args.base_url)


if __name__ == "__main__":
    raise SystemExit(main())
