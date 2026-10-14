#!/usr/bin/env python3
"""Waybar module: Claude subscription usage (5h session / 7d weekly)."""
import json
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

CREDS = Path.home() / ".claude/.credentials.json"
CACHE = Path.home() / ".cache/waybar-claude-usage.json"
URL = "https://api.anthropic.com/api/oauth/usage"
ICON = "\U000F06A9"
MAX_AGE = 300        # seconds a fresh result is reused without a request
BACKOFF = 600        # default wait after a 429 without Retry-After


def out(text, tooltip, cls="", pct=0):
    print(json.dumps({"text": f"{ICON}  {text}", "tooltip": tooltip, "class": cls, "percentage": pct}))


def fmt_reset(iso, fmt):
    if not iso:
        return "—"
    return datetime.fromisoformat(iso.replace("Z", "+00:00")).astimezone().strftime(fmt)


def render(data, note=""):
    five = data.get("five_hour") or {}
    week = data.get("seven_day") or {}
    s = round(five.get("utilization") or 0)
    w = round(week.get("utilization") or 0)
    top = max(s, w)
    cls = "critical" if top >= 90 else "warning" if top >= 75 else ""
    tooltip = (
        f"Session (5h): {s}% — resets {fmt_reset(five.get('resets_at'), '%H:%M')}\n"
        f"Weekly: {w}% — resets {fmt_reset(week.get('resets_at'), '%a %H:%M')}"
    )
    out(f"{s}% / {w}%", tooltip + (f"\n{note}" if note else ""), cls, top)


def load_cache():
    try:
        return json.loads(CACHE.read_text())
    except Exception:
        return {}


def save_cache(cache):
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(json.dumps(cache))


def fetch():
    oauth = json.loads(CREDS.read_text())["claudeAiOauth"]
    if oauth.get("expiresAt", 0) / 1000 < time.time():
        raise RuntimeError("token expired — run claude to refresh")
    req = urllib.request.Request(URL, headers={
        "Authorization": f"Bearer {oauth['accessToken']}",
        "anthropic-beta": "oauth-2025-04-20",
        "User-Agent": "waybar-claude-usage",
    })
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r)


def main():
    cache = load_cache()
    now = time.time()
    if cache.get("data") and (now - cache.get("fetched", 0) < MAX_AGE or now < cache.get("retry_after", 0)):
        return render(cache["data"])
    if not cache.get("data") and now < cache.get("retry_after", 0):
        until = datetime.fromtimestamp(cache["retry_after"]).strftime("%H:%M")
        return out("?", f"Rate limited — retrying after {until}")

    try:
        data = fetch()
    except Exception as e:
        if isinstance(e, urllib.error.HTTPError) and e.code == 429:
            try:
                wait = int(e.headers.get("Retry-After") or BACKOFF)
            except ValueError:
                wait = BACKOFF
            cache["retry_after"] = now + wait
            save_cache(cache)
        if not cache.get("data"):
            return out("?", f"Claude usage error: {e}")
        as_of = datetime.fromtimestamp(cache["fetched"]).strftime("%H:%M")
        return render(cache["data"], f"(stale: {e}, as of {as_of})")

    save_cache({"data": data, "fetched": now, "retry_after": 0})
    render(data)


try:
    main()
except Exception as e:
    out("?", f"Claude usage error: {e}")
