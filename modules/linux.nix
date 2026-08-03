{ pkgs, ... }:


{
  # Fixes XDG_DATA_DIRS, locale archive, man pages and .desktop integration
  # when Home Manager runs on a foreign distro.
  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;

  # The daemon-installed Nix lives here. /etc/profile.d/nix.sh only exports it
  # for login shells and returns early once __ETC_PROFILE_NIX_SOURCED is set,
  # so pin it explicitly to keep `nix` available in every shell flavour.
  home.sessionPath = [ "/nix/var/nix/profiles/default/bin" ];

  home.packages = with pkgs; [
    distrobox
    # usbimager
    # heaptrack
  ];
}
