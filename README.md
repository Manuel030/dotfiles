# dotfiles

This repository contains my personal dotfiles managed with Nix and Home Manager.

## Setup

To set up these dotfiles on a new system, follow these steps:

1. Install Nix if it's not already installed on your system.

2. Add the necessary channels:


```
nix-channel --add https://nixos.org/channels/nixpkgs-24.05-darwin nixpkgs
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
```
