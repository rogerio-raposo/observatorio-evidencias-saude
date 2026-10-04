#!/usr/bin/env python3
"""Reference renderer for the OES Evidence Sheet neutral template.

This is a validation/reference implementation only. It intentionally supports
only the tiny template subset documented by the OES project:
  - {{path}}
  - {{this}}
  - {{#if path}} ... {{else}} ... {{/if}}
  - {{#each path}} ... {{/each}}

It does not make scientific decisions and does not mutate the input payload.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

TAG_RE = re.compile(r"(\{\{.*?\}\})", re.DOTALL)
MISSING = object()


@dataclass
class Text:
    value: str


@dataclass
class Var:
    path: str


@dataclass
class If:
    path: str
    yes: list[Any]
    no: list[Any]


@dataclass
class Each:
    path: str
    children: list[Any]


def tokenize(template: str) -> list[str]:
    return [part for part in TAG_RE.split(template) if part != ""]


def tag_value(token: str) -> str:
    return token[2:-2].strip()


def parse(tokens: list[str]) -> list[Any]:
    nodes, index, stop = _parse_block(tokens, 0, set())
    if stop is not None or index != len(tokens):
        raise ValueError("Unexpected template terminator")
    return nodes


def _parse_block(
    tokens: list[str], index: int, stop_tags: set[str]
) -> tuple[list[Any], int, str | None]:
    nodes: list[Any] = []

    while index < len(tokens):
        token = tokens[index]

        if not token.startswith("{{"):
            nodes.append(Text(token))
            index += 1
            continue

        tag = tag_value(token)

        if tag in stop_tags:
            return nodes, index, tag

        if tag.startswith("#if "):
            path = tag[4:].strip()
            yes, index, stop = _parse_block(tokens, index + 1, {"else", "/if"})
            no: list[Any] = []

            if stop == "else":
                no, index, stop = _parse_block(tokens, index + 1, {"/if"})

            if stop != "/if":
                raise ValueError(f"Unclosed if block for {path}")

            nodes.append(If(path, yes, no))
            index += 1
            continue

        if tag.startswith("#each "):
            path = tag[6:].strip()
            children, index, stop = _parse_block(
                tokens, index + 1, {"/each"}
            )
            if stop != "/each":
                raise ValueError(f"Unclosed each block for {path}")
            nodes.append(Each(path, children))
            index += 1
            continue

        if tag in {"else", "/if", "/each"} or tag.startswith("/"):
            raise ValueError(f"Unexpected tag: {tag}")

        nodes.append(Var(tag))
        index += 1

    if stop_tags:
        return nodes, index, None

    return nodes, index, None


def _walk(value: Any, parts: Iterable[str]) -> Any:
    current = value
    for part in parts:
        if isinstance(current, dict) and part in current:
            current = current[part]
        else:
            return MISSING
    return current


def resolve(path: str, root: Any, current: Any) -> Any:
    if path == "this":
        return current

    parts = path.split(".")

    if isinstance(current, dict) and parts[0] in current:
        value = _walk(current, parts)
        if value is not MISSING:
            return value

    return _walk(root, parts)


def truthy(value: Any) -> bool:
    return value is not MISSING and value is not None and bool(value)


def map_value(path: str, value: Any, presentation: dict[str, Any]) -> Any:
    if value is None or value is MISSING:
        return value

    mapping = presentation.get(path)
    if mapping is None:
        mapping = presentation.get(path.split(".")[-1])

    if mapping is None:
        return value

    if isinstance(value, bool):
        key = "true" if value else "false"
    else:
        key = str(value)

    return mapping.get(key, value)


def stringify(path: str, value: Any, presentation: dict[str, Any]) -> str:
    if value is MISSING:
        raise KeyError(f"Active template variable not found in view: {path}")

    value = map_value(path, value, presentation)

    if value is None:
        return ""
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (dict, list)):
        return json.dumps(
            value,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
    return str(value)


def render_nodes(
    nodes: list[Any],
    root: Any,
    current: Any,
    presentation: dict[str, Any],
) -> str:
    output: list[str] = []

    for node in nodes:
        if isinstance(node, Text):
            output.append(node.value)
            continue

        if isinstance(node, Var):
            value = resolve(node.path, root, current)
            output.append(stringify(node.path, value, presentation))
            continue

        if isinstance(node, If):
            value = resolve(node.path, root, current)
            branch = node.yes if truthy(value) else node.no
            output.append(render_nodes(branch, root, current, presentation))
            continue

        if isinstance(node, Each):
            value = resolve(node.path, root, current)
            if value is MISSING or value is None:
                continue
            if not isinstance(value, list):
                raise TypeError(
                    f"Template each target is not a list: {node.path}"
                )
            for item in value:
                output.append(
                    render_nodes(node.children, root, item, presentation)
                )
            continue

        raise TypeError(f"Unsupported node: {type(node)!r}")

    return "".join(output)


def render(template: str, payload: Any, presentation: dict[str, Any]) -> str:
    nodes = parse(tokenize(template))
    return render_nodes(nodes, payload, payload, presentation)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--presentation-map", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    presentation = json.loads(
        Path(args.presentation_map).read_text(encoding="utf-8")
    )

    rendered = render(template, payload, presentation)

    if "{{" in rendered or "}}" in rendered:
        raise RuntimeError("Unresolved template token found after rendering")

    Path(args.output).write_text(rendered, encoding="utf-8")


if __name__ == "__main__":
    main()
