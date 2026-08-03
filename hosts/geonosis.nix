{ ... }:

# MacBook (aarch64-darwin), hostname: geonosis

{
  imports = [
    ../modules/core.nix
    ../modules/editors.nix
    ../modules/dev.nix
    ../modules/gui.nix
    ../modules/darwin.nix
  ];

  home.username = "manuel";
  home.homeDirectory = "/Users/manuel";
  home.stateVersion = "26.05";
}
