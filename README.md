# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and git.

Each top-level directory is a stow **package** whose contents mirror `$HOME`.
Running `stow <package>` from this directory symlinks its files into your home
directory; the real files live here, under version control.

## Layout

```
dotfiles/
├── agents/  → ~/.agents/{AGENTS.md, skills/{caveman,grill-me}}   # ← single source of truth
├── bash/    → ~/.bashrc, ~/.profile, ~/.bash_logout
├── git/     → ~/.gitconfig
├── claude/  → ~/.claude/{settings.json, statusline-command.sh, CLAUDE.md, skills→.agents}
├── codex/   → ~/.codex/{config.toml, AGENTS.md→.agents, skills→.agents}
├── cosmic/  → ~/.config/cosmic/…, ~/.local/bin/cosmic-lock-blank
└── fcitx5/  → ~/.xinputrc, ~/.config/fcitx5/profile
```

**`~/.agents/` is the single source of truth** for shared agent instructions and
skills — a neutral location owned by no single tool. Each tool points into it:

- **Prompt:** `~/.agents/AGENTS.md` holds the instructions (concise chat style;
  Claude Code gets it from the built-in `Concise` output style, set in
  `claude/.claude/settings.json`). `~/.codex/AGENTS.md` is a
  symlink to it (Codex reads `AGENTS.md` natively); `~/.claude/CLAUDE.md` is just
  `@~/.agents/AGENTS.md` (a Claude Code import).
- **Skills:** `~/.agents/skills/{caveman,grill-me}` are the real skills; both
  `~/.claude/skills/*` and `~/.codex/skills/*` symlink to them.

**Edit the files under `~/.agents/`** (repo: `agents/.agents/`) and every tool
stays in sync. (Promoted from a per-project setup.)

## COSMIC: blank the screen on lock

COSMIC locks the session but leaves the displays lit. `cosmic/` overrides the
`LockScreen` system action so the lock shortcut (`Super`+`Esc`) also powers the
displays off via [`wlopm`](https://git.sr.ht/~leon_plickat/wlopm); any key or
mouse movement wakes them back to the lock prompt.

Overrides in `~/.config/cosmic/…/v1/system_actions` are merged over the defaults
in `/usr/share/cosmic/`, so naming one action leaves the rest intact.

`wlopm` is the only extra dependency — install it per machine (see below).

> Two limitations, both inherent to cosmic-comp:
>
> - **Blanking cannot be its own shortcut.** While the session is locked,
>   cosmic-comp runs only `Terminate`, `Debug`, input-source switch, brightness,
>   volume, and mute; every other action, custom `Spawn` bindings included, is
>   dropped (`src/input/actions.rs`). So locking and blanking must be one action.
> - **The panel's power-menu "Lock Screen" does not blank.** It calls logind
>   directly, bypassing `system_actions`. Covering every lock path would need a
>   systemd user unit reacting to logind's `Lock` signal.

## fcitx5: Vietnamese input

`~/.xinputrc` selects fcitx5 through im-config, which exports the
`*_IM_MODULE`/`XMODIFIERS` variables at login and autostarts fcitx5.
`profile` holds two input methods, `keyboard-us` and `unikey` (Telex);
`Ctrl`+`Space` toggles between them. Takes effect after re-login.

Only `profile` is tracked. fcitx5 writes the rest of `~/.config/fcitx5/`
itself, so stow it with `--no-folding` to keep that dir real and out of the repo.

## Setup on a new machine

```bash
sudo apt install -y stow wlopm fcitx5 fcitx5-unikey           # or your package manager
git clone https://github.com/MinhxNguyen7/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow agents bash git claude codex cosmic                      # symlink everything into ~
stow --no-folding fcitx5
```

> If a target file already exists (e.g. a stock `~/.bashrc`), stow will refuse
> with a conflict. Either remove/back up the existing file first, or use
> `stow --adopt <package>` to pull the existing file into the repo (review the
> resulting diff before committing).

## Everyday usage

```bash
cd ~/dotfiles
stow <package>      # link a package into ~
stow -R <package>   # restow — after adding/removing files in a package
stow -D <package>   # unlink a package from ~
```

## Adding a new dotfile

```bash
# Recreate the file's path-relative-to-$HOME inside the matching package,
# then move the real file in and stow it.
mkdir -p ~/dotfiles/<pkg>/<subdir>
mv ~/<path> ~/dotfiles/<pkg>/<path>
cd ~/dotfiles && stow -R <pkg>
git add -A && git commit -m "Add <path>"
```

## Excluded on purpose

Secrets and machine state are **never** tracked (enforced by `.gitignore`):
auth credentials (`~/.claude/.credentials.json`, `~/.codex/auth.json`),
shell/session history, session logs, `*.sqlite` databases, caches, and
per-machine `settings.local.json`.

## Tool-managed files that drift

Some tools rewrite their own config/state into files this repo tracks, so
expect occasional spurious `git` changes. Strip the machine-specific bits back
out before committing — only portable config belongs here.

- **`codex/.codex/config.toml`** — Codex writes runtime *state* back into this
  file: per-project `[projects."/abs/path"]` trust entries, the
  `[tui.model_availability_nux]` counter, and `[hooks.state]`. Because the file
  is symlinked into the repo, those reappear after Codex sessions. Keep only the
  portable keys (`model`, `model_reasoning_effort`, `personality`,
  `service_tier`, `[mcp_servers.*]`); drop the rest.
- **`bash/.bashrc`** — the `# >>> conda initialize >>>` block is owned by
  `conda init` and may be regenerated with an absolute install path
  (`/home/<user>/miniconda3`). Re-apply the `$HOME/miniconda3` form if that
  happens, so it stays portable.
