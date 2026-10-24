# ai-assisted-code-review

A single Claude Code skill. The repo root *is* the skill: `SKILL.md` is the
instructions, `RATIONALE.md` records why they are shaped that way.

- `RATIONALE.md` is written by the user. Do not edit it; propose changes in chat.
- `nix build` packages the two files under `share/agent-skills/ai-assisted-code-review/`
  for the separate agent-skills project that installs them. Nothing else ships.
- `devenv test` runs `nix flake check --no-build`. Git hooks (secrets scan, nix/shell lint,
  Conventional Commits) install on shell entry and must pass; never `--no-verify`.
- devenv `scripts.*` with real logic: use nushell (`package = pkgs.nushell`);
  CLI args need `def --wrapped main [...args]`, interpolation is `$"(...)"`.
