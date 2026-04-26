# Development Agent Guidance

Use this file only when the user asks to develop, debug, refactor, publish,
review, or change documentation for this repo itself.

For normal household TV control, follow root `AGENTS.md` and `wiki/Agent Runbook.md` instead.

## Development Goal

Ship small, production-ready repo changes that keep the TV agent reliable.

- Prefer minimal, durable diffs at the right abstraction level.
- Preserve the TV-agent user experience: concise, non-technical, action-oriented.
- Treat TV-facing changes as real household automation changes, not toy scripts.
- If behavior cannot be verified, say so and give exact commands or checks.

## Workflow

- Start with read-only exploration before editing.
- Keep changes inside the repo.
- Do not modify global configs, host state, or dotfiles outside this repo.
- Ask targeted questions only when a blocking decision is unclear.
- Use numbered discussion only for blocking choices, risks, or questions.
- For complex features or significant refactors, use an ExecPlan from `.agent/PLANS.md`.

Detailed references, read only when needed:

- `.agent/docs/workflow.md`
- `.agent/docs/implementation.md`
- `.agent/PLANS.md`
- `.agent/docs/continuity.md`

## Code And Script Rules

- Prefer repo-local scripts in `scripts/` over one-off terminal incantations.
- Shared TV target resolution belongs in `scripts/lib/tv-target.sh`.
- Shared local environment handling belongs in `scripts/lib/local-env.sh`.
- TV-facing scripts should support `TV_ADB_SERIAL`.
- Mutating TV-facing scripts should support `--serial` and `--dry-run` when practical.
- Quote Android shell arguments carefully. URLs with `&`, `?`, spaces, or shell metacharacters must not split on the remote shell.
- Fail fast. Do not swallow errors silently.
- Keep shell scripts readable; avoid cleverness that makes TV actions harder to audit.

## Validation

Project checks:

- Build: none currently.
- Typecheck: none currently.
- Shell syntax: `bash -n scripts/*`.
- Shell lint: `shellcheck scripts/*` if available.
- Mutating TV scripts: use `--dry-run` first when supported.
- Real TV tests: run against `TV_ADB_SERIAL` only when the user wants the TV changed.
- Termux installer: test with `termux/termux-docker:aarch64` when changing install behavior.

After adding or changing TV-facing functionality, ask the user to confirm the TV result. ADB success only proves the command was accepted.

## Docs And Wiki

Keep docs aligned with behavior:

- `README.md` is human/product-oriented.
- Root `AGENTS.md` is the TV-agent operating contract.
- `.agent/development-agent.md` is only for repo-development guidance.
- `wiki/` is the agent memory and operational synthesis layer.
- `wiki/Agent Runbook.md` is the first stop before TV-facing actions.

Update `wiki/` when changes affect device facts, command recipes, app behavior,
content preferences, setup, troubleshooting, or future agent behavior.

Do not mark played or tested media as liked, preferred, or favorite unless the user explicitly says so.

## Dependencies And Host Policy

- Do not install host packages.
- Termux setup is handled by `scripts/install-termux`.
- Termux uninstall is handled by `scripts/uninstall-termux`.
- If tooling such as `shellcheck` is missing, say so and provide the command the user can run.
- Do not reintroduce generic Debian/apt support unless the user explicitly asks.

## Secrets And Public Repo Safety

- Never print secrets to terminal output.
- Do not ask users to paste secrets.
- Local config files such as `.env` and `.tv-serial` must stay ignored.
- `.agent/CONTINUITY.md` is session history and should stay ignored.
- Before public publishing, inspect staged files for private household details the user may not want public.

## Continuity

If `.agent/CONTINUITY.md` exists locally, use it for session continuity when resuming work or after compaction. Do not assume it will exist in public clones.

Update it only when there is a meaningful delta in goal, constraints, decisions, state, open questions, working set, or important tool outcomes.
