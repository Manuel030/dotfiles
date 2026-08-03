{ pkgs, unstable, config, ... }:

# Desktop applications, terminal emulator and fonts.

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  xdg.configFile = {
    "Code/User/settings.json".source = makeLink "settings.json";
    "Code/User/keybindings.json".source = makeLink "keybindings.json";
    "kitty/kitty.conf".source = makeLink "kitty.conf";
  };

  home.packages = with pkgs; [
    audacity
    brave
    bruno
    google-chrome
    kitty
    nerd-fonts.jetbrains-mono
    obsidian
    postman
    scrcpy
    unstable.slack # NOTE: unsupported on aarch64-linux
    vscode
  ];
}
