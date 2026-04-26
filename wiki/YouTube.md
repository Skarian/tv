# YouTube

YouTube on the Shield uses the Android TV package `com.google.android.youtube.tv`.

## Saved Presets

Use `scripts/yt` for saved YouTube presets. This is the preferred path for common videos because it avoids long shell commands and URL quoting mistakes.

```sh
scripts/yt --list
scripts/yt PRESET_SLUG
```

Saved presets live in `data/youtube-presets.tsv`.

Use a saved preset immediately only when the user names it or clearly identifies a single saved item. For broad platform-ambiguous categories, first confirm the app/service. Once YouTube is specified or chosen, use saved presets as context for picking by default.

Use `scripts/play-youtube` only as the lower-level primitive for new YouTube video IDs and full YouTube URLs.

`scripts/yt` and `scripts/play-youtube` stop known background media apps before launching by default. Use `--no-stop-media` only when deliberately debugging app-switching behavior.

## Launching URLs

When the user provides a full URL, quote it locally:

```sh
scripts/play-youtube 'https://www.youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID&start_radio=1'
```

The script must also quote the URL for the remote Android shell. ADB runs `shell` commands through `/system/bin/sh` on the Shield, so URL characters such as `&`, `?`, spaces, and shell metacharacters can split or corrupt the remote command if they are not escaped before being sent to the device.

Dry-run when changing scripts, debugging quoting, or using an unusual URL:

```sh
scripts/play-youtube --dry-run 'https://www.youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID&start_radio=1'
```

The launch script handles background media cleanup before starting YouTube:

```sh
scripts/play-youtube 'https://www.youtube.com/watch?v=VIDEO_ID'
```

Spotify can keep the active audio session after YouTube accepts an intent, so this cleanup is baked into `scripts/play-youtube` rather than left to the agent.

## Playlist Context With A Specific Video

When the user asks for a YouTube playlist and names a specific video or episode inside it, launch a watch URL that includes both the selected video id and the playlist id:

```sh
scripts/play-youtube 'https://www.youtube.com/watch?v=VIDEO_ID&list=PLAYLIST_ID&index=INDEX'
```

The video id is the primary selector. The `list` parameter asks YouTube to preserve playlist context so next/previous can follow the playlist, and `index` is useful when known but should not replace the explicit video id.

If the playlist id is not obvious from search results, inspect the channel playlist listing or the candidate playlist with `yt-dlp --flat-playlist` before launching. Do not substitute a shorts, compilation, or unofficial playlist when the user asked for the main playlist unless that is the best available match and is stated clearly.

After launch, verify the current video through `scripts/remote status`. Android media-session metadata usually reports the current video title and channel but not whether YouTube honored playlist context. Treat playlist context as confirmed only when the TV UI or next/previous behavior shows the playlist queue.

Confirmed example:

```text
DragonBall Z Abridged playlist context: https://www.youtube.com/watch?v=BSJTGla19o4&list=PL6EC7B047181AD013&index=48
```

## Finding Videos From Natural Language

For broad requests such as "play Christmas music", first ask what app/service to use when the app is not explicit. Once YouTube is specified or chosen, search once and pick the best fit by default.

Use `yt-dlp` search for structured no-key YouTube discovery:

```sh
yt-dlp --skip-download --flat-playlist \
  --print '%(title)s\t%(channel)s\t%(duration_string)s\t%(webpage_url)s' \
  'ytsearch5:QUERY'
```

If the user asks for options, present results with title, channel, duration, and URL. Then ask which one to play.

By default, search once, state the pick and why, then launch it.

Search results can include non-video or playlist-like entries, so choose the clearest playable result and avoid ambiguous entries unless the user asks for options.

## Verification

After launching, do not report success from intent delivery alone. Verify playback using [[TV Control]]:

```sh
scripts/remote status
```

Look for `com.google.android.youtube.tv`, `state=3`, and metadata matching the requested video when metadata is available. If the first check shows old metadata or a non-playing state immediately after launch, treat it as pending rather than wrong playback; wait briefly and recheck before reporting success or failure.

Known failure mode: YouTube may open to an account/profile sign-in page while another app, such as Spotify, continues playing in the background. In that state, ADB accepted the YouTube intent but playback did not switch to YouTube. The default launch script now stops known background media first; if playback still does not switch, verify media session ownership and ask the user to confirm audio/on-screen behavior.

## Related

- [[TV Control]]
- [[Content Preferences]]
