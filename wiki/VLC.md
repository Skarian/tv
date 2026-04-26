# VLC

VLC on the Shield uses the Android TV package `org.videolan.vlc`.

## Direct URL Playback

When the user provides a direct video URL and explicitly asks to play it in VLC, use VLC instead of Stremio or YouTube. This is useful for resolved media links such as `.mkv` files.

Stop current media first unless the user explicitly says not to interrupt anything. Then launch an Android `ACTION_VIEW` intent targeted at VLC:

```sh
bash -lc 'source scripts/lib/tv-target.sh && serial="$(require_tv_serial)" && url="VIDEO_URL" && adb -s "$serial" shell am start -a android.intent.action.VIEW -d "$url" -t "video/*" -p org.videolan.vlc'
```

Quote the URL locally and for the remote shell. Direct media URLs often contain `%`, `&`, `?`, spaces, brackets, and other characters that must not be allowed to split the command.

After launch, verify through [[TV Control]]:

```sh
scripts/remote status
```

Look for package `org.videolan.vlc`, `state=3`, and metadata matching the provided file or title when VLC exposes metadata. As with other media launches, intent acceptance is not playback success; ask the user to confirm TV/audio behavior if metadata is missing or unclear.

## Start At A Specific Position

VLC accepts a `position` long extra in milliseconds on the launch intent. To start a direct URL at 11 minutes, pass `--el position 660000`:

```sh
bash -lc 'source scripts/lib/tv-target.sh && serial="$(require_tv_serial)" && url="VIDEO_URL" && adb -s "$serial" shell am start -a android.intent.action.VIEW -d "$url" -t "video/*" -p org.videolan.vlc --el position 660000'
```

After launch, `scripts/remote status` may report VLC's current `PlaybackState` position, which can be used to confirm the seek. Example verified behavior: launching a direct `.mkv` URL with `--el position 660000` started VLC at `position=660000`.

## Related

- [[TV Control]]
- [[Agent Runbook]]
