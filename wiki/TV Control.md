# TV Control

## Device

The TV automation target is an NVIDIA Shield Pro running Android TV.

Scripts resolve the TV target in this order:

1. `TV_ADB_SERIAL`
2. `.tv-serial`
3. ADB's selected/default device

`TV_ADB_SERIAL` can be exported in the shell or placed in ignored `.env`.

Device identity:

- Manufacturer: `NVIDIA`
- ADB devices model: `SHIELD_Android_TV`
- Getprop model: `SHIELD Android TV`
- Device: `mdarcy`

## ADB Notes

- `adb connect TV_IP:5555` is the expected direct connection form.
- Do not rely on `adb mdns services` to find this Shield. It previously did not list the working target because the Shield is reached through classic ADB-over-TCP on port `5555`.
- Ping may fail even when ADB works.

## Reconnecting When the IP Changes

First try the non-escalating path:

```sh
adb devices -l
arp -a
adb connect IP:5555
adb -s SERIAL shell getprop ro.product.manufacturer
adb -s SERIAL shell getprop ro.product.model
adb -s SERIAL shell getprop ro.product.device
```

If `adb devices -l` already shows connected `HOST:PORT` candidates in `device` state, verify them with `getprop`.

If the Shield is not already connected, use `arp -a` to get LAN IPv4 candidates, try `adb connect IP:5555`, and verify any candidate that becomes a connected `device`.

When repo files are available, use the helper for the same workflow:

```sh
scripts/connect-tv
```

`scripts/connect-tv` first tries the saved target. If that fails, it checks visible ADB devices and ARP candidates, then scans for TCP `5555`, connects with ADB, and verifies the device identity before saving `.tv-serial` and `TV_ADB_SERIAL` in `.env`.

The recovery strategy is intentionally based on TCP `5555` plus device identity verification, not mDNS.

`.tv-serial` is local runtime state. It is intentionally ignored by git so reconnects can update it without creating unrelated repo changes.

A device is accepted as the TV only when it reports:

- Manufacturer: `NVIDIA`
- Model containing `SHIELD`
- Device: `mdarcy`

This recovery path was tested with the Shield disconnected from ADB. It works by checking `adb devices -l`, ARP candidates, `adb connect IP:5555`, and then the `getprop` identity checks.

If the IP is known, pass it directly:

```sh
scripts/connect-tv TV_IP:5555
```

## Script Conventions

- Put reusable entrypoints in `scripts/`.
- TV-facing scripts should support `TV_ADB_SERIAL`; mutating ADB scripts should also support `--serial` and `--dry-run` when practical.
- Read-only diagnostics may skip `--dry-run` when their output requires inspecting the device.
- ADB scripts should resolve the target through `scripts/lib/tv-target.sh` unless there is a specific reason not to.
- Local repo config should live in ignored `.env`; use `.env.example` as the public template.
- Do not preflight `.env` before routine commands. If a TV command reports missing target config, run `scripts/connect-tv`; if a Sonos command reports missing host config, run `scripts/connect-sonos`.
- Termux environment setup should go through `scripts/install-termux`; dependency notes live in [[Termux Setup]].

## Power Control

The Shield remains reachable over ADB while asleep. Power control should use `scripts/power`:

```sh
scripts/power status
scripts/power on
scripts/power off
scripts/power toggle
```

Use `on` for "turn on the TV" and `off` for "turn off the TV". `on` sends `KEYCODE_WAKEUP`; `off` sends `KEYCODE_POWER`; `toggle` sends `KEYCODE_POWER` without checking direction.

Interpret "turn it off" as TV power off by default. The exception is a combined wallpaper request such as "turn it off and put up the wallpaper." In that context, "it" means the current media, because a wallpaper cannot be seen if the TV is powered off. Use `scripts/stop-media`, then keep the display on or wake it before starting wallpaper.

This setup was observed with HDMI-CEC enabled and Shield auto TV on/off flags enabled. `KEYCODE_WAKEUP` moved the Shield from `Asleep/OFF` to `Awake/ON`. `KEYCODE_POWER` moved it back to `Asleep/OFF`. `KEYCODE_SLEEP` was not reliable enough to use as the off path.

`scripts/power on` and `scripts/power off` poll `dumpsys power` with short early waits that grow over time, up to the command timeout. TV-side HDMI-CEC behavior can lag behind the Shield state; ask the user to confirm the visible TV state after changing this behavior.

## Aerial Views Wallpaper

The Shield uses Aerial Views as its Android TV wallpaper/screensaver:

```text
com.neilturner.aerialviews/com.neilturner.aerialviews.ui.screensaver.DreamActivity
```

Use the repo helper for wallpaper control:

```sh
scripts/wallpaper status
scripts/wallpaper on
scripts/wallpaper off
scripts/remote wallpaper-on
scripts/remote wallpaper-off
```

`scripts/wallpaper on` stops known media apps first, then starts Aerial Views. `scripts/stop-media` includes Aerial Views so media launch scripts dismiss it before playback. Direct remote key actions call `scripts/wallpaper off-if-active` before sending the keyevent so the wallpaper does not remain over the intended app action.

Wallpaper is only useful when the display is on. If a request combines stopping media with showing wallpaper, do not power the TV off first. If the TV is already asleep or off, run `scripts/power on` before `scripts/wallpaper on`.

The Shield exposes the dream manager as the `dreams` service but does not expose the `cmd dreams` shell command. Use `service call dreams 1` to start the configured dream and `service call dreams 2` to awaken/stop it. Do not launch `DreamActivity` with `am start`; Aerial Views registers it as a `DreamService`, not as a normal activity.

## Media Playback Verification

Do not treat launch-command success as playback success. Android can put one media app in the foreground while another app keeps the active audio session.

After launching media, check:

```sh
scripts/remote status
```

When the agent is doing follow-up logic, use JSON mode for compact parsing:

```sh
scripts/remote status --json
scripts/stremio-state --json
scripts/stremio-status --json
```

Prefer these keys for conditional logic:

- `remote status --json`: `result`, `has_media_session`, `adb_available`
- `stremio-state --json`: `state`, `source`, `elapsed_ms`, `marker`
- `stremio-status --json`: `has_stremio_session`, `has_playing_state`
- `stremio-stream next --json`: `result`, `state`, `action`, `switch_sent_ms`, `confirmed`

Launch scripts print compact completion tags on standard output:

```sh
scripts/play-youtube ... ; # result=success
scripts/play-spotify ... ; # result=success
scripts/play-stremio ... ; # result=success
scripts/yt ... ; # result=success
```

The active media session should belong to the intended package and should have playback metadata that matches the requested media when metadata is available.

Immediately after an intent launch, media-session metadata can be stale from the previous playback. Treat stale metadata with `state=0`, missing media-button ownership, or unchanged title/artist as an indeterminate launch state, not as evidence that the old content is playing. Wait briefly and recheck, or send a deliberate play command when the app is foregrounded but idle. Only report the requested media as playing after the intended package has `state=3` and metadata has refreshed or otherwise matches the requested item.

If the wrong app still owns the active session after using the repo launch scripts, treat that as an exception: run `scripts/stop-media`, retry the launch once, verify again, and ask the user what happened on the TV. Do not report success from intent delivery alone.

Movies and scripted TV series default to Stremio on this TV; do not ask what app/service to use for those requests. For vague music, ambience, playlist, or platform-ambiguous non-movie/non-series media requests, ask what app/service to use. Once YouTube or Spotify is specified or chosen, default to having the agent search and pick the best fit; present options only when the user asks for options. Skip the service question when the request already specifies the service, exact item, URL, preset, movie, or TV-series episode.

Media launch scripts stop known background media before launching by default:

```sh
scripts/play-youtube 'https://www.youtube.com/watch?v=VIDEO_ID'
scripts/play-spotify 'https://open.spotify.com/playlist/PLAYLIST_ID'
scripts/play-stremio --type movie tt0133093
scripts/play-stremio --type series --video-id tt1520211:11:24 tt1520211
```

Stremio launches use the normal background-media cleanup, which includes Stremio, then pause briefly and press OK after the detail page opens by default. They attempt to start playback from a clean Stremio state rather than only opening the page.

For Stremio stream switching after playback has started, use:

```sh
scripts/stremio-stream next
scripts/stremio-stream prev
```

The stream-switch helper reports `switch_sent_ms` when the replacement stream has been selected. Full playback confirmation is opt-in with `--confirm` because stream resolution can take much longer than the user-facing action.

Use `scripts/stop-media` directly only for manual cleanup or debugging. This force-stops known media apps that may keep playing in the background.

Use raw `adb dumpsys media_session` when debugging or when `scripts/remote status` is not enough:

```sh
adb -s TV_IP:5555 shell dumpsys media_session
```

## Related

- [[App Configuration]]
- [[Content Preferences]]
- [[Spotify]]
- [[Stremio]]
- [[YouTube]]
- [[Termux Setup]]
