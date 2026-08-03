# dotfiles

This repository contains my personal dotfiles managed with Nix and Home Manager.

## Hosts

| Host | System | Profile |
| --- | --- | --- |
| `geonosis` (MacBook) | `aarch64-darwin` | core + editors + dev + gui + darwin |
| `raspberrypi` (Pi 5, Debian bookworm) | `aarch64-linux` | core + editors + linux |

### Adding a host

1. Create `hosts/<hostname>.nix` importing the modules it needs and setting
   `home.username` / `home.homeDirectory` / `home.stateVersion`.
2. Register it in `flake.nix` under `homeConfigurations` via `mkHome`.
3. Verify without building:
   `nix eval '.#homeConfigurations."<user>@<hostname>".activationPackage.drvPath'`

## Setup

To set up these dotfiles on a new system, follow these steps:

1. Install Nix if it's not already installed on your system.

2. Install Home Manager.

3. Run


```
home-manager switch --flake ~/path/to/directory/containing/flake/
```

Home Manager resolves `homeConfigurations."<user>@<hostname>"` automatically, so
the same command works on every host. On a machine with pre-existing dotfiles
(e.g. Debian's `~/.bashrc`), add `-b bak` to back up conflicting files.

