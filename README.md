# My Mac Setup

A small, opinionated setup for making a fresh Mac feel like mine again.

It gives me a keyboard-driven floating window manager, a comfortable shell,
and a handful of terminal tools I use every day. Everything lives in this repo,
so moving to a new Mac is mostly a matter of running one script and granting one
macOS permission.

## Quick start

Already cloned?

```sh
cd ~/Dev/my-mac-setup
./install.sh
```

On a completely fresh system, macOS may first open the Xcode Command Line Tools
installer. Let it finish, then run `./install.sh` once more.

## What you get

- **yabai + skhd** for fast window positioning without forcing a tiling layout
- **Zsh + Powerlevel10k** with completions, suggestions, syntax highlighting,
  fzf-tab, and Zinit
- **lazygit** for working with Git without remembering every command
- **yazi** for quick file browsing from the terminal
- **fzf, zoxide, and jq** for the small things that make terminal work nicer
- Two tiny native helpers that keep windows inside the usable screen area and
  move the cursor along with a window
- An optional low-animation macOS profile for a faster, calmer desktop

Homebrew and the Xcode Command Line Tools are installed automatically when
needed. The Meslo Nerd Font used by Powerlevel10k is included as well.

## The installer asks two questions

### Keep a backup?

Before replacing any existing config files, the installer asks:

```text
Back up existing configuration files before replacing them? [Y/n]
```

Press Enter to keep a backup. Existing files are moved to a timestamped folder
under `~/.my-mac-setup-backups/`.

For unattended runs:

```sh
BACKUP_EXISTING_CONFIGS=yes ./install.sh
BACKUP_EXISTING_CONFIGS=no ./install.sh
```

### Reduce macOS animations?

Near the end, the installer asks:

```text
Apply reduced macOS animation settings? [y/N]
```

This one defaults to **no**. Choosing yes speeds up or removes several window,
scrolling, Dock, Finder, and Mail animations. It does not change SIP or any
security setting.

You can apply or undo the animation tweaks at any time:

```sh
./macos/reduce-animations.sh
./macos/restore-animations.sh
```

For an unattended install, use `REDUCE_ANIMATIONS=yes ./install.sh`.

Some of these preferences are undocumented macOS defaults. Apple may ignore or
change individual keys in future macOS releases. Restart open applications or
log out if a change is not visible immediately.

## One manual step: Accessibility

yabai and skhd need permission to control windows and receive global shortcuts.
After installation, open:

**System Settings → Privacy & Security → Accessibility**

Enable both `yabai` and `skhd`. If they were already listed, toggle them off and
back on. Then restart the services:

```sh
yabai --restart-service
skhd --restart-service
```

Finally, open a new terminal or reload Zsh with `exec zsh`.

If prompt icons look wrong, select **MesloLGS Nerd Font** in your terminal's font
settings. Installing a font does not make macOS select it automatically.

## Window shortcuts

| Shortcut | What it does |
| --- | --- |
| `Ctrl + Alt + Left/Right` | Left or right half |
| `Ctrl + Alt + Up/Down` | Top or bottom half |
| `Alt + 7/9/1/3` | Screen quarters |
| `Alt + C` | Center the active window |
| `Alt + Enter` | Toggle native fullscreen |
| `Alt + J/K` | Focus the previous or next Space |
| `Alt + Shift + Left/Right` | Send the window to another display |
| `Alt + Shift + H/L` | Send the window to the previous or next Space |

The last shortcut requires yabai's scripting addition and a partially disabled
System Integrity Protection configuration. The installer deliberately leaves
that decision alone. Everything else works without changing SIP. If you want
Space-moving support, follow the upstream
[yabai scripting addition guide](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)).

## Where things live

The configs are kept in `config/`, the native helper sources in `helpers/`, and
the optional macOS preference scripts in `macos/`.

The installer links the configs into `~/.config`, so editing a file in this repo
changes the active setup. It also creates `~/.yabairc` and `~/.skhdrc` links for
Homebrew LaunchAgent versions that still expect the older paths.

Compiled helpers end up in `~/.local/bin`:

- `visible-frame` finds the part of a display not covered by the menu bar or Dock.
- `cursor-warp` lets the pointer follow a window to another display.

## Updating

```sh
cd ~/Dev/my-mac-setup
git pull
./install.sh
```

Running the installer again is expected. Files already linked correctly are
left alone.

## Something not working?

Start with the included check:

```sh
./check.sh
```

If window management is the problem, these usually tell the story:

```sh
yabai -m query --displays
tail -n 50 /tmp/yabai_"$USER".err.log
tail -n 50 /tmp/skhd_"$USER".err.log
```

An accessibility error means the macOS permission needs attention. If yabai
responds but shortcuts do nothing, restart skhd and check its log.
