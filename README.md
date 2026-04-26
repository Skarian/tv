# TV Agent

A personal TV assistant for controlling an NVIDIA Shield, Stremio, YouTube,
Spotify, Aerial Views, and Sonos from natural-language requests.

The goal is simple: ask for what you want on the TV, and let the agent handle
the lookup, app choice, launch, volume, and basic recovery steps.

## What It Can Do

- Play movies and scripted TV through Stremio.
- Find and launch specific TV episodes, including episode requests by plot or scene.
- Play YouTube videos, playlists, and saved presets.
- Launch Spotify playlists.
- Control play, pause, back, home, and other remote actions.
- Control Sonos volume and mute.
- Turn the TV on or off.
- Start or stop the Aerial Views wallpaper/screensaver.
- Switch Stremio streams when a source is bad.
- Remember confirmed preferences and device behavior in the local wiki.

## Example Requests

```text
play The Matrix
play the Simpsons episode where Homer removes the crayon from his brain
turn it down
pause
try another stream
put up the wallpaper
play a Spotify workout playlist
```

Movies and scripted TV go through Stremio by default. Music and broader media
requests may need a quick app choice if the request does not specify YouTube,
Spotify, a URL, or a saved preset.

## Setup

When used through Dispatch, Termux dependencies are declared in:

```text
.dispatch/termux-dependencies.json
```

Dispatch installs missing packages and tracks package ownership when the
assistant is created.

After the assistant workspace exists, connect the TV and Sonos:

```sh
scripts/connect-tv
scripts/connect-sonos
```

Device discovery writes local ignored config so future requests can act directly.
If you already know the device IPs, pass them directly:

```sh
scripts/connect-tv TV_IP:5555
scripts/connect-sonos SONOS_IP
```

For manual non-Dispatch setup, see `wiki/Termux Setup.md`.

To preview manual fallback package removal:

```sh
bash scripts/uninstall-termux --dry-run
```

## Agent Notes

Operational details for agents live in `AGENTS.md` and `wiki/`, starting with
`wiki/Agent Runbook.md`. Local device config stays in ignored files such as
`.env` and `.tv-serial`.
