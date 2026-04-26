# Remote Controls

General controls live in `scripts/remote`. Exact soundbar volume control lives in `scripts/sonos`.

```sh
scripts/remote status
scripts/remote vol-up
scripts/remote vol-down
scripts/remote mute
scripts/remote play-pause
scripts/remote pause
scripts/remote play
scripts/remote stop
scripts/remote power-on
scripts/remote power-off
scripts/remote power
scripts/remote back
scripts/remote home
scripts/remote up
scripts/remote down
scripts/remote left
scripts/remote right
scripts/remote ok
```

## Volume

Volume should be controlled directly through Sonos, not through Shield ADB volume keyevents.

If a volume command reports missing Sonos config, run `scripts/connect-sonos` to discover and save `SONOS_HOST` in ignored `.env`. You can also export `SONOS_HOST` in the shell or pass `--host HOST`. The working control path is local Sonos UPnP `RenderingControl`:

```sh
export SONOS_HOST=SONOS_IP
scripts/sonos status
scripts/sonos volume
scripts/sonos volume 25
scripts/sonos up 10
scripts/sonos down 10
scripts/sonos up 1
scripts/sonos down 1
scripts/sonos mute
scripts/sonos unmute
scripts/sonos toggle-mute
```

For convenience, `scripts/remote vol-up`, `scripts/remote vol-down`, and `scripts/remote mute` delegate to `scripts/sonos`.

Plain requests to increase or decrease volume should use a 10 percentage point adjustment. One step means 1 percentage point and should only be used when the user asks for a step, a tiny adjustment, or an exact 1% change.

The earlier Shield ADB volume routes failed for this setup:

- `adb shell input keyevent KEYCODE_VOLUME_DOWN` did not change the soundbar volume.
- `cmd media_session volume --show --stream 3 --adj lower` did not change the effective TV/soundbar volume.
- Android reported `STREAM_MUSIC` at `15/15`, which is not authoritative for this audio path.
- HDMI-CEC volume control appeared disabled in Android settings, while the physical Shield remote still controlled volume, likely through an IR or vendor-specific path.

Do not retry ADB keyevents as the primary volume mechanism unless the user asks to investigate a new setup. Use Sonos UPnP first.

## Media And Navigation

Media, navigation, and power controls still use Android keyevents:

- `KEYCODE_MEDIA_PLAY_PAUSE`
- `KEYCODE_MEDIA_PAUSE`
- `KEYCODE_MEDIA_PLAY`
- `KEYCODE_MEDIA_STOP`
- `KEYCODE_WAKEUP` through `scripts/power on`
- `KEYCODE_POWER` through `scripts/power off` and `scripts/power toggle`
- `KEYCODE_BACK`
- `KEYCODE_HOME`
- `KEYCODE_DPAD_UP`
- `KEYCODE_DPAD_DOWN`
- `KEYCODE_DPAD_LEFT`
- `KEYCODE_DPAD_RIGHT`
- `KEYCODE_DPAD_CENTER`

`scripts/remote status` prints Sonos volume/mute state when `SONOS_HOST` is configured, Android `STREAM_MUSIC` details, and active media session details from `dumpsys media_session`.

For direct power checks or JSON output, use:

```sh
scripts/power status --json
scripts/power on --json
scripts/power off --json
```

## Presets

No volume presets are saved yet.

The values `25%` and `5%` were used as tests and should not be treated as preferences unless the user explicitly says so.

If the user repeatedly adjusts to the same approximate Sonos volume over time, ask whether to save that as a named preset. Do not infer a preference from one adjustment.

## Related

- [[TV Control]]
