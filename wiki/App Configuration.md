# App Configuration

This page tracks app-level operational preferences, installed-version guidance, and settings that affect TV automation. Content taste and media choices belong in [[Content Preferences]].

## Stremio

The user prefers Stremio Android TV `1.8.4` on the Shield because newer builds showed playback reliability problems. Avoid updating Stremio unless the user explicitly asks.

Disable Google Play auto-update to keep the downgraded Stremio version installed. On NVIDIA Shield / Android TV:

```text
Home -> Apps -> Google Play Store -> profile icon -> Settings -> Auto-update apps -> Don't auto-update apps
```

If the Shield Play Store exposes a per-app Stremio auto-update toggle, use that instead of disabling global auto-updates. The global setting is the reliable fallback. Avoid `Update all`, because it may update Stremio.

## Related

- [[Content Preferences]]
- [[Stremio]]
- [[TV Control]]
