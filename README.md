# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and git.

Each top-level directory is a stow **package** whose contents mirror `$HOME`.
Running `stow <package>` from this directory symlinks its files into your home
directory; the real files live here, under version control.

## Layout

```
dotfiles/
├── bash/    → ~/.bashrc, ~/.profile, ~/.bash_logout
├── git/     → ~/.gitconfig
├── claude/  → ~/.claude/{settings.json, statusline-command.sh, CLAUDE.md, skills/}
└── codex/   → ~/.codex/{config.toml, AGENTS.md, skills/}
```

`~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` are global instruction files
(auto-loaded by Claude Code / Codex) that activate the `caveman` skill at
`lite` intensity each session. The `caveman` and `grill-me` skills live under
both `skills/` dirs. These were promoted from a per-project setup.

## Setup on a new machine

```bash
sudo apt install -y stow                                      # or your package manager
git clone https://github.com/MinhxNguyen7/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow bash git claude codex                                    # symlink everything into ~
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
