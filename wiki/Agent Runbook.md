# Agent Runbook

This page is the first stop before taking action against the TV setup.

Read this page and the one linked page for the current task area once per session or task area. Reuse that context for follow-ups such as "again", "down actually", "pause", or "play another one". Reread only if the repo changed, the task switches area, compaction occurred, a command fails, or the user asks for implementation details.

Do not inspect scripts just to restate their behavior. Inspect scripts when the wiki is missing information, a command fails, or implementation details are requested.

## Fast Path

Movies and scripted TV series default to Stremio. Do not ask what app/service to use for requests like "play The Matrix", "watch The Simpsons", "latest episode of Walking Dead", or plot-description episode prompts. Resolve the title or episode and launch through [[Stremio]].

For vague music, ambience, playlist, or platform-ambiguous non-movie/non-series media requests, ask what app/service to use before searching, choosing, or launching:

```text
What app should I use?
```

Once YouTube or Spotify is specified or chosen, search once and pick the best fit by default. Present options only when the user asks for options.

It is fine to ask the service question only when that is natural, but do not skip it for broad platform-ambiguous requests such as "play lofi", "Christmas music", or "Disney songs".

Skip these questions only when the user provides an exact URL, named preset, or exact item.

Saved content preferences are context for choosing. Do not surface saved preferences by default as a substitute for asking the app/service question when the service is ambiguous.

For natural-language YouTube or Spotify discovery, search once, choose the best fit, state the reason, and launch. If the user asks for options, present candidates instead.

For playback launches, use repo scripts. They stop known background media apps by default:

```sh
scripts/yt PRESET_SLUG
scripts/play-youtube 'https://www.youtube.com/watch?v=VIDEO_ID'
scripts/play-spotify 'https://open.spotify.com/playlist/PLAYLIST_ID'
scripts/play-stremio --type movie tt0133093
scripts/play-stremio --type series --video-id tt1520211:11:24 tt1520211
```

For machine-friendly follow-up logic, use the JSON form on status checks:

```sh
scripts/remote status --json
scripts/stremio-state --json
scripts/stremio-status --json
scripts/stremio-stream next --json
```

All of these JSON outputs use stable keys for parse-first handling:

```text
scripts/remote status --json    -> result, has_media_session, adb_available
scripts/stremio-state --json    -> state, source, marker, elapsed_ms
scripts/stremio-status --json   -> has_stremio_session, has_playing_state
scripts/stremio-stream next --json -> result, dry_run, state, action, direction, count, confirmed, switch_sent_ms
```

Playback launch scripts now emit compact completion tags:

- `result=success` for normal completion.
- `result=dry_run` when `--dry-run` is used.

When you learn a durable behavior detail, a repeating failure, or a user-approved preference, update the relevant wiki page during that session.

For Stremio stream problems after playback has started, switch streams instead of relaunching the title. Use the context-free helper; it detects whether Stremio is in the player or stream picker before sending keys:

```sh
scripts/stremio-stream next
scripts/stremio-stream prev
scripts/stremio-stream next 3
```

Use `scripts/stremio-stream next --confirm` only when the user asks for confirmation or when debugging. Otherwise report the `switch_sent_ms` timing as the user-impact latency.

After launching media, verify playback as described in [[TV Control]], then ask the user to confirm the TV/audio behavior.

Interpret "turn it off" as TV power off by default. The exception is a combined request such as "turn it off and do the wallpaper" or "turn it off and put up the wallpaper"; in that context, "it" means the current playback. Stop playback, leave or wake the display on, then start Aerial Views.

## Routing

| Request type | First page to read | Primary script |
| --- | --- | --- |
| Explicitly turn TV on/off, wake, sleep, power toggle | [[TV Control]] | `scripts/power` or `scripts/remote power-on` / `power-off` |
| Stop current playback, or "turn it off" paired with showing wallpaper | [[TV Control]] | `scripts/stop-media` |
| Start or stop Aerial Views wallpaper/screensaver | [[TV Control]] | `scripts/wallpaper` or `scripts/remote wallpaper-on` / `wallpaper-off` |
| Volume, mute, sound level, louder, quieter | [[Remote Controls]] | `scripts/sonos` |
| Play, pause, back, home, media buttons | [[Remote Controls]] | `scripts/remote` |
| YouTube URLs, YouTube search, saved YouTube presets | [[YouTube]] | `scripts/yt` or `scripts/play-youtube` |
| Spotify playlists or Spotify search | [[Spotify]] | `scripts/play-spotify` |
| Movies, scripted TV series, Stremio requests, episodes, plot-description episode prompts | [[Stremio]] | `scripts/cinemeta`, then `scripts/play-stremio` |
| Explicit VLC playback for a provided video URL | [[VLC]] | Android `ACTION_VIEW` intent to `org.videolan.vlc` |
| First-run setup, Shield reconnect, Sonos discovery, changed IP | [[TV Control]] | `scripts/connect-tv`, `scripts/connect-sonos` |
| User likes, favorites, recurring media | [[Content Preferences]] | update wiki after confirming preference |

## Volume Defaults

Volume is controlled through Sonos with `scripts/sonos`; first-run setup should discover the speaker with `scripts/connect-sonos`.

Do not use Shield ADB volume keyevents for volume. They were tested and failed for this setup.

Do not check `.env` before every volume command. Run the command; if it reports missing Sonos config, run `scripts/connect-sonos` and retry.

Plain requests such as "increase volume" or "turn it down" use a 10 percentage point adjustment:

```sh
scripts/sonos up 10
scripts/sonos down 10
```

One step means 1 percentage point. Use `scripts/sonos up 1` or `scripts/sonos down 1` only when the user asks for one step, a tiny adjustment, or an exact 1% change.

For exact targets like "put it to 25%", use:

```sh
scripts/sonos volume 25
```

## Media Defaults

Agents should normally use `scripts/yt`, `scripts/play-youtube`, `scripts/play-spotify`, and `scripts/play-stremio` instead of manually composing `adb shell am start` commands.

For Stremio, the agent should handle simple requests end to end from natural language. Do the selection work explicitly: use `scripts/cinemeta` to inspect candidates or episodes, use web research when the prompt gives only plot/scene memory, choose the correct id from the user's request and context, then pass that explicit id or route to `scripts/play-stremio`.

When a Stremio request identifies an episode by plot, quote, scene, guest, or vague memory, use web research or another reliable reference to identify the episode before mapping it to Stremio ids with `scripts/cinemeta`.

`scripts/play-stremio` waits 8 seconds and presses OK once after opening the detail page by default, so normal Stremio requests should attempt to start playback through the focused action/source screen. Use `--no-press-ok` only when the user explicitly wants the detail page or when debugging launch behavior.

For "bad stream", "try another", or "previous stream" requests, use `scripts/stremio-stream` or the `scripts/next-stream` / `scripts/prev-stream` shorthands. Do not guess with ad hoc `Back, Down, OK` sequences. The stream-switch helper distinguishes player, stream picker, and non-switchable states before sending keys.

Those scripts run `scripts/stop-media` before launching unless explicitly passed `--no-stop-media`. For Stremio, that cleanup includes the default Stremio package and the launcher waits briefly before launch so a prior Stremio screen or player state does not interfere. Use `--no-stop-media` only when deliberately debugging app-switching behavior. Use `scripts/stop-media` directly only for manual cleanup or debugging.

Delivering an Android intent is not success. Verify the active media session when possible and ask the user to confirm what happened on the TV.

For routine household TV-control requests, keep replies terse: result plus essential timing or failure only. Examples: `Switched stream in 2.7s.`, `Playing Princess Diaries 2.`, or `Volume lowered to 33%.` Use detailed reasoning, command output, timings, logs, and diagnostic context when the user is developing or debugging repo behavior, or explicitly asks for details.

Do not turn one-off test values or played media into content preferences. Ask before saving a content preference or preset.
