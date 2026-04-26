# Wiki Principles

This repo uses a lightweight Karpathy-style LLM wiki, but its source of truth is different from a research wiki.

In Karpathy's original framing, the wiki is maintained from research sources. In this repo, the user's requests, corrections, and preferences are the primary source of truth. Device output, command results, and web research are supporting material used to fill in mechanics, metadata, and verification.

The wiki should be useful to both the user and future agents. It should read like compact reference material rather than a transcript.

## Maintenance Rules

- Add durable user preferences, repeated actions, device facts, scripts, URLs, and troubleshooting lessons to the wiki.
- Keep clean boundaries: `AGENTS.md` defines operating rules for agents; `wiki/` contains the TV knowledge base, app-specific recipes, app configuration, content preferences, and tested commands.
- Keep routine TV interactions lightweight. Agents should read the runbook and relevant wiki page once, then reuse that context for rapid follow-ups instead of rereading files before every command.
- Reorganize the wiki as it grows. When a section becomes a distinct topic, split it into its own page and update links from the index and related pages.
- When the user gives a correction about how the wiki should work, update the wiki rules and the relevant page.
- After adding or changing TV-facing functionality, ask the user to confirm what happened on the TV. A command can succeed from ADB's point of view while still producing the wrong on-screen result.
- Movies and scripted TV series default to Stremio; do not ask what app/service to use for those requests. For vague music, ambience, playlists, or other platform-ambiguous non-movie/non-series media, ask what app/service to use. Once YouTube or Spotify is specified or chosen, default to having the agent search and pick the best fit; present options only when the user asks for options. Skip the service question when the request already specifies the service, exact item, URL, preset, movie, or TV-series episode.
- For media launches, intent delivery is not success. Verify the active media session belongs to the intended app and ask the user to confirm audio/on-screen behavior. For Stremio stream switching after playback has already started, prioritize `switch_sent_ms` as the user-impact timing; run confirmation only when requested or debugging.
- Proactively ask whether new behavior, preferences, URLs, device findings, or troubleshooting lessons should be added to the wiki. The agent should prompt for wiki maintenance instead of relying on the user to remember.
- Do not confuse tested playback with preference. A media item belongs in [[Content Preferences]] only when the user explicitly says they like it, want it saved, or want it as a preset. App version and settings preferences belong in [[App Configuration]].
- When saving a YouTube URL, include what the video is. Prefer title, channel, and video ID when available.
- When handling natural-language YouTube requests, search once, pick the best fit, state the reason, and launch by default. If the user asks for options, present candidates with title, channel, duration, and URL.
- When presenting Spotify playlist candidates, include short context such as owner/source, item or save counts, and a few sample tracks when available.
- After presenting media candidates, make the next step explicit. For YouTube and Spotify, candidates are shown only when the user asks for options; otherwise the agent should pick the best fit.
- Keep prose clean and browseable. Avoid chatty notes, raw transcripts, and audit-log style annotations.
- Use command output and web research to verify details, not to replace the user's stated intent.

## Related

- [[TV Control]]
- [[App Configuration]]
- [[Content Preferences]]
