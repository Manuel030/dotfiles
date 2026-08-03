{ ... }:

# Raspberry Pi 5 (aarch64-linux) running Raspberry Pi OS / Debian bookworm,
# hostname: raspberrypi
#
# Deliberately lean: CLI + terminal editors only. Add ../modules/dev.nix or
# ../modules/gui.nix here if the Pi ever needs toolchains or desktop apps.

{
  imports = [
    ../modules/core.nix
    ../modules/editors.nix
    ../modules/linux.nix
  ];

  home.username = "manuel";
  home.homeDirectory = "/home/manuel";
  home.stateVersion = "26.05";

  # pi-coding-agent ships its own node runtime here. Its installer cannot patch
  # ~/.bashrc (Home Manager owns it), so the PATH entry lives here instead.
  # "current" is a stable symlink, so node upgrades don't break it.
  home.sessionPath = [ "$HOME/.local/share/pi-node/current/bin" ];
}
