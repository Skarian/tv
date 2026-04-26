# Stremio

Stremio on the Shield uses the Android TV package `com.stremio.one`.

This is the default service for movies and scripted TV series on this TV. Do not ask which app/service to use for movie or TV-series requests. Handle simple title requests, episode requests, latest/first/season-specific requests, and plot-description requests end to end from natural language.

## Agentic Lookup Flow

Use `scripts/cinemeta` for lookup and selection context:

```sh
scripts/cinemeta search movie 'the matrix'
scripts/cinemeta search series 'walking dead'
scripts/cinemeta seasons tt1520211
scripts/cinemeta episodes tt1520211 11
```

The agent should inspect these results and decide what the user meant. Do not hide title, media-type, or episode selection inside the launcher.

If the user describes an episode by plot, quote, scene, guest, or vague memory, Cinemeta may not contain enough text to identify it. Use web research or another reliable reference to identify the title/season/episode first, then use `scripts/cinemeta` to confirm the series id and episode id for Stremio. Cite or summarize the evidence when the match was inferred from outside sources.

For straightforward title requests, choose the obvious canonical result without asking for options. Ask a clarifying question only when the title or requested episode remains genuinely ambiguous after Cinemeta and reasonable research.

After choosing an explicit id or route, use `scripts/play-stremio` to launch Stremio playback:

```sh
scripts/play-stremio --type movie tt0133093
scripts/play-stremio --type series tt1520211
scripts/play-stremio --type series --video-id tt1520211:11:24 tt1520211
scripts/play-stremio 'stremio:///detail/movie/tt0133093'
```

`scripts/play-stremio` stops known background media apps before launching by default. The default cleanup includes Stremio through `scripts/stop-media`, then waits briefly before sending the new intent, so launches start from a clean Stremio app state instead of inheriting a previous title, source screen, or paused player. If a non-default package is passed with `--package`, the launcher also force-stops that target package. Use `--no-stop-media` only when deliberately debugging app-switching behavior. Tune the post-stop pause with `--launch-delay SECONDS`.

By default, `scripts/play-stremio` waits 8 seconds after opening the detail page and then sends the remote OK button (`KEYCODE_DPAD_CENTER`) once to start playback from the focused action/source screen. Use `--no-press-ok` when intentionally opening only the detail page. Tune with `--ok-delay SECONDS`, `--ok-count COUNT`, and `--ok-gap SECONDS` when debugging launch timing.

## Android TV Version

The user prefers Stremio Android TV `1.8.4` on the Shield because newer builds showed playback reliability problems. Avoid updating Stremio unless the user explicitly asks. App-level version and auto-update preferences are tracked in [[App Configuration]].

Observed downgrade process from `1.10.0-rc.15` to `1.8.4`:

1. Check the installed Stremio version on the Shield.
2. Download a trusted Stremio Android TV APK/XAPK for the desired version.
3. Cross-check package identity and source where possible. APKPure supplied the usable XAPK; APKMirror was used as a cross-check for package/version metadata.
4. Extract the APK splits from the XAPK.
5. Try a non-destructive downgrade install:

```sh
adb install-multiple -r -d SPLIT_APKS...
```

6. If the downgraded app crashes on launch, clear only Stremio app data/cache, then launch it again. This resets Stremio login, addons, and settings.
7. Disable Play Store auto-update afterward so the Shield does not overwrite the pinned version.

## Stream Switching

For requests such as "this stream is bad", "try another stream", "change streams", or "go back to the previous stream", use the stream-switching helpers instead of manual key sequences:

```sh
scripts/stremio-stream next
scripts/stremio-stream prev
scripts/stremio-stream next 3
scripts/next-stream
scripts/prev-stream
```

The default stream switch is context-free. It observes the current TV state and only acts when the screen is already in a switchable Stremio state:

- `player`: detected from Android media session when `com.stremio.one` is actively playing. The helper sends `Back`, then the requested direction/count, then `OK`.
- `stream_picker`: detected from Stremio accessibility text containing stream-provider markers such as `Torrentio`, `StremThru`, `Comet`, `MediaFusion`, `DMM`, or `AIOStreams`. The helper sends the requested direction/count, then `OK`.
- `detail_or_other`: the helper does not send blind navigation by default. It exits with `action=needs_media_context`.

When the current state is not switchable and the requested media is known, pass explicit media context so the helper may relaunch the Stremio detail page before choosing a stream:

```sh
scripts/stremio-stream --type movie --id tt0247638 next
scripts/stremio-stream --type series --id tt1520211 --video-id tt1520211:11:24 next
```

Confirmation is opt-in with `--confirm`. The important user-facing timing is `switch_sent_ms`, which means the new stream was selected. Use `--confirm` only when the user asks whether playback actually resumed or when debugging:

```sh
scripts/stremio-stream next --confirm
```

`scripts/stremio-status` prints compact Stremio media-session state. `scripts/stremio-state` classifies the current state as `player`, `stream_picker`, or `detail_or_other` using media-session state and Stremio accessibility text. `scripts/stremio-action` batches D-pad actions for debugging, and `scripts/stremio-screenshot` captures fast resized/cropped screenshots for manual visual inspection. The screenshot helper assumes the current Shield framebuffer is `3840x2160` RGBA; if display output changes, its crop/resize output may need adjustment.

## Cinemeta Resolution

Cinemeta search endpoints return Stremio ids that usually match IMDb ids:

```text
https://v3-cinemeta.strem.io/catalog/movie/top/search=The%20Matrix.json
https://v3-cinemeta.strem.io/catalog/series/top/search=walking%20dead.json
```

Confirmed examples:

- `The Matrix` resolves to movie id `tt0133093`.
- `The Walking Dead` resolves to series id `tt1520211`.

For episode requests, use `scripts/cinemeta seasons SERIES_ID` to inspect season structure and `scripts/cinemeta episodes SERIES_ID [SEASON]` to inspect episode ids:

```sh
scripts/cinemeta seasons tt1520211
scripts/cinemeta episodes tt1520211 11
```

The same data is available from the full series metadata:

```text
https://v3-cinemeta.strem.io/meta/series/tt1520211.json
```

Confirmed example:

- `The Walking Dead` season 11 has 24 Cinemeta episodes, and S11E24 has episode id `tt1520211:11:24`.
- A plot-description request like "the Simpsons episode where he removes the crayon from his brain" requires outside episode knowledge first. Web references identify it as `HOMR`, Season 12 Episode 9; Cinemeta then maps `The Simpsons` to `tt0096697` and the episode to `tt0096697:12:9`.

## Deep Links

Stremio accepts Android VIEW intents for these detail routes:

```text
stremio:///detail/movie/tt0133093
stremio:///detail/series/tt1520211/tt1520211:11:24
```

The Shield resolves those links to:

```text
com.stremio.one/com.stremio.tv.MainActivity
```

## Behavior

These launches open Stremio detail pages and then press OK once by default to start playback. They still do not prove playback started.

After launching, verify foreground state or playback using [[TV Control]]. If `--no-press-ok` was used, a detail-page launch may leave `scripts/remote status` with no active media session, which is expected until the user starts a stream.

## Related

- [[Agent Runbook]]
- [[App Configuration]]
- [[Content Preferences]]
- [[TV Control]]
