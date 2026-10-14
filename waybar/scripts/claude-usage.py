#!/usr/bin/env python3
"""Waybar module: Claude subscription usage (5h session · 7d weekly)."""
import json
import time
import urllib.request
from datetime import datetime
from pathlib import Path

CREDS = Path.home() / ".claude/.credentials.json"
URL = "https://api.anthropic.com/api/oauth/usage"
ICON = "󰚩"


def out(text, tooltip, cls="", pct=0):
    print(json.dumps({"text": f"{ICON}  {text}", "tooltip": tooltip, "class": cls, "percentage": pct}))


def fmt_reset(iso, fmt):
    if not iso:
        return "—"
    return datetime.fromisoformat(iso.replace("Z", "+00:00")).astimezone().strftime(fmt)


def main():
    oauth = json.loads(CREDS.read_text())["claudeAiOauth"]
    if oauth.get("expiresAt", 0) / 1000 < time.time():
        return out("–", "Token expired — run claude to refresh")

    req = urllib.request.Request(URL, headers={
        "Authorization": f"Bearer {oauth['accessToken']}",
        "anthropic-beta": "oauth-2025-04-20",
        "User-Agent": "waybar-claude-usage",
    })
    with urllib.request.urlopen(req, timeout=10) as r:
        data = json.load(r)

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
    out(f"{s}% / {w}%", tooltip, cls, top)


try:
    main()
except Exception as e:
    out("?", f"Claude usage error: {e}")
