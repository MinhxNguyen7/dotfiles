---
name: update-dotfiles
description: >
  Maintain the GNU Stow dotfiles repo at ~/dotfiles in both directions: sync down
  (git pull --ff-only, then restow), and commit back (strip tool-managed drift,
  restow, conventional-commit, push). Use when the user says "update/pull/sync/push
  dotfiles", after editing anything under ~/.agents, ~/.claude, ~/.codex, ~/.bashrc,
  or ~/.gitconfig, or when adding a shared skill. Knows this repo's exact layout,
  fold state, and drift sources.
---

# Update Dotfiles

Personal dotfiles at `~/dotfiles`, managed with **GNU Stow** + git. Each top-level
dir is a stow **package** mirroring `$HOME`. Real files live in the repo; stow
symlinks them into `~`.

Packages: `agents` (→ `~/.agents`), `bash` (→ `~/.bashrc`/`.profile`/`.bash_logout`),
`git` (→ `~/.gitconfig`), `claude` (→ `~/.claude`), `codex` (→ `~/.codex`).

`~/.agents/` is the **single source of truth** for shared agent instructions and
skills. Each tool points into it: `~/.codex/AGENTS.md` symlinks to
`~/.agents/AGENTS.md`; `~/.claude/CLAUDE.md` imports it via `@~/.agents/AGENTS.md`.

Shared skills live in `agents/.agents/skills/<name>/`. Both tools expose all of
them, wired differently:

- **Claude:** `claude/.claude/skills` is a single symlink → `agents/.agents/skills`.
  Every shared skill appears automatically; no per-skill wiring.
- **Codex:** `codex/.codex/skills/` is a real dir of per-skill symlinks, because
  codex owns `.system/` inside it and the dir can't be a plain symlink. Each new
  shared skill needs its own symlink here.

## Sync down (pull)

```bash
cd ~/dotfiles
git status                 # if dirty → do "Commit back" first, or `git stash`
git pull --ff-only
stow -R agents bash git claude codex   # idempotent; relinks any added/removed files
```

`~/.claude/skills` is a single symlink → the shared skills dir, so skills pulled
into the repo appear in `~` with no restow. `~/.codex/skills` is a real dir (codex's
own `.system/` prevents folding), so its per-skill symlinks need the `stow -R`.

## Commit back (push)

Some tools rewrite state into files this repo tracks. **Strip the machine-specific
bits before staging** — only portable config belongs here.

```bash
cd ~/dotfiles
git status
git diff                   # inspect every change; hunt for drift below
```

Drift to strip:

| File | Drift written by the tool | Keep only |
|------|---------------------------|-----------|
| `codex/.codex/config.toml` | `[projects."/abs/path"]` trust entries, `[tui.model_availability_nux]` counter, `[hooks.state]` | `model`, `model_reasoning_effort`, `personality`, `service_tier`, `[mcp_servers.*]` |
| `bash/.bashrc` | `conda init` block regenerated with absolute `/home/<user>/miniconda3` | re-apply the `$HOME/miniconda3` form |

Secrets and machine state are never tracked (enforced by `.gitignore`): credentials,
history, session logs, `*.sqlite`, caches, per-machine `settings.local.json`. If a
new file of that kind shows up staged, it does not belong — leave it out.

Then commit (Conventional Commits) and push:

```bash
git add -A
git commit -m "<type>: <description>"   # e.g. feat(skills): add update-dotfiles
git push
```

## Add a shared skill (or other new dotfile)

Real skill dir goes under the `agents` package. Claude picks it up automatically
(whole-dir symlink); only codex needs a per-skill symlink.

```bash
mkdir -p ~/dotfiles/agents/.agents/skills/<name>
# write SKILL.md ...
cd ~/dotfiles
ln -s ../../../agents/.agents/skills/<name> codex/.codex/skills/<name>
stow -R codex            # propagate the codex symlink into ~
git add -A && git commit -m "feat(skills): add <name>" && git push
```

Any other new dotfile: recreate its `$HOME`-relative path inside the matching
package, move the real file in, `stow -R <pkg>`, then commit.

## Gotchas

- Run stow from `~/dotfiles` (its top level), never a subdir.
- Stow refuses on conflict if a real file already occupies the target. Back it up,
  or `stow --adopt <pkg>` to pull the existing file into the repo (review the diff).
- The repo stores relative symlinks (e.g. `../../../agents/.agents/skills/<name>`);
  keep them relative so they survive being stowed into `~`.
- After `git pull --ff-only` fails on divergence, do not force — reconcile manually.
