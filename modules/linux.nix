{ pkgs, ... }:


{
  # Fixes XDG_DATA_DIRS, locale archive, man pages and .desktop integration
  # when Home Manager runs on a foreign distro.
  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    distrobox
    # usbimager
    # heaptrack
  ];
}
