#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "requests<3",
# ]
# ///


from __future__ import annotations

import argparse
import json
from time import monotonic
from typing import Any

import requests


DEFAULT_URLS = [
    "https://formentor-api.galilea.ai/version",
    "https://randa-api.galilea.ai/v1/version",
    "https://palma-api.galilea.ai/v1/version",
    "https://adriano-api.galilea.ai/v1/app-version",
]


def transform_for_env(url: str, env: str) -> str:
    """Insert the env token before '.galilea.ai' for test/dev environments.

    Examples:
      https://palma-api.galilea.ai/v1/version -> https://palma-api.dev.galilea.ai/v1/version
    """
    if env == "prod":
        return url

    marker = ".galilea.ai"
    if marker in url:
        parts = url.split(marker, 1)
        return f"{parts[0]}.{env}{marker}{parts[1]}"
    return url


def fetch(url: str, timeout: float = 5.0) -> dict[str, Any]:
    """Fetch a single URL with a fixed timeout and return a serializable result dict.

    Kept simple and synchronous for readability.
    """
    start = monotonic()
    try:
        resp = requests.get(url, timeout=timeout)
        elapsed = monotonic() - start
        result: dict[str, Any] = {
            "url": url,
            "status_code": resp.status_code,
            "elapsed": round(elapsed, 3),
        }
        # Try to decode JSON, fall back to text (truncated)
        try:
            payload = resp.json()
            result["json"] = payload
        except Exception:
            text = resp.text or ""
            result["text"] = text[:1000]
        return result
    except requests.Timeout as exc:
        return {"url": url, "error": "timeout", "detail": str(exc)}
    except requests.RequestException as exc:
        return {"url": url, "error": "request_error", "detail": str(exc)}


def pretty_print(result: dict[str, Any]) -> None:
    """Print a single result in a readable format."""
    url = result.get("url")
    status = result.get("status_code")
    elapsed = result.get("elapsed")
    err = result.get("error")

    # Minimal ANSI coloring
    BLUE = "\x1b[34m"
    GREEN = "\x1b[32m"
    RED = "\x1b[31m"
    YELLOW = "\x1b[33m"
    RESET = "\x1b[0m"

    print("─" * 72)
    print(f"{BLUE}URL:{RESET} {url}")
    if err:
        print(f"{RED}Error:{RESET} {err}")
        if "detail" in result:
            print(f"  {result['detail']}")
        return

    print(f"Status: {GREEN if status and status < 400 else RED}{status}{RESET}    Elapsed: {elapsed}s")

    if "json" in result:
        payload = result["json"]
        # If common shape contains 'version', surface it first
        if isinstance(payload, dict) and "version" in payload:
            print(f"{YELLOW}version:{RESET} {payload['version']}")
            # print rest if more keys exist
            rest = {k: v for k, v in payload.items() if k != "version"}
            if rest:
                print("Payload:")
                print(json.dumps(rest, indent=2, ensure_ascii=False))
        else:
            print("JSON payload:")
            print(f"{YELLOW}version:{RESET} {payload}")
    else:
        text = result.get("text", "")
        if text:
            print("Response text (truncated):")
            print(text.strip())


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Fetch version endpoints and print results")
    parser.add_argument("--env", choices=("prod", "test", "dev"), default="prod",
                        help="Environment to target: prod (default), test, or dev")

    args = parser.parse_args(argv)

    # If environment is prod, use the stable list. For test/dev, use the single dev fallback URL.
    if args.env == "prod":
        urls = DEFAULT_URLS
    else:
        urls = [transform_for_env(u, args.env) for u in DEFAULT_URLS]

    for u in urls:
        r = fetch(u)
        pretty_print(r)

    print("─" * 72)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
