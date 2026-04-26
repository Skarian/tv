# Spotify

Spotify on the Shield uses the Android TV package `com.spotify.tv.android`.

## Launching Playlists

Spotify accepts `ACTION_VIEW` deep links for `https://open.spotify.com/...` URLs, including playlists.

Use the repo launcher:

```sh
scripts/play-spotify 'https://open.spotify.com/playlist/PLAYLIST_ID'
```

This was tested with playlist URLs and started playback.

`scripts/play-spotify` stops known background media apps before launching by default. Use `--no-stop-media` only when deliberately debugging app-switching behavior.

Confirm playback using [[TV Control]]:

```sh
scripts/remote status
```

Look for `com.spotify.tv.android`, `state=3`, and metadata matching the expected playlist when metadata is available. Spotify may briefly retain stale metadata from a previous session after accepting a playlist intent. If the first check shows `state=0`, no media-button session owner, or old title/artist metadata, treat it as pending: wait and recheck, or send `scripts/remote play` once, then verify again before reporting success.

## Finding Playlists Without API Credentials

For natural-language playlist discovery, use web search plus Spotify oEmbed.

Search DuckDuckGo through Jina for Spotify playlist URLs:

```text
https://r.jina.ai/http://duckduckgo.com/html/?q=site:open.spotify.com/playlist QUERY
```

Extract `https://open.spotify.com/playlist/PLAYLIST_ID` candidates.

Enrich known URLs with Spotify oEmbed:

```text
https://open.spotify.com/oembed?url=URL_ENCODED_SPOTIFY_PLAYLIST_URL
```

For sample tracks, read the embed page through Jina:

```text
https://r.jina.ai/http://open.spotify.com/embed/playlist/PLAYLIST_ID
```

When the user asks for options, present candidates with title, owner/source, item or save counts if available, and several sample tracks. Do not present only titles and URLs.

By default, search once, choose the best fit, state the pick and the reason, then launch. Present candidates only when the user asks for options.

## Tested Playlists

No personal Spotify playlist examples are committed in the public repo.

## Related

- [[TV Control]]
- [[Content Preferences]]
