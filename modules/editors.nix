{ pkgs, config, ... }:

# Terminal editors and their out-of-store configs. Plugin management stays
# with lazy.nvim, not Nix.

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  xdg.configFile = {
    "helix/config.toml".source = makeLink "helix/config.toml";
    "helix/languages.toml".source = makeLink "helix/languages.toml";
    "helix/themes/default-transparent.toml".source = makeLink "helix/default-transparent.toml";
    "nvim/lua".source = makeLink "nvchad/lua";
  };

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    # NvChad config: init.lua loaded here, lua/ symlinked via xdg.configFile
    # Plugins are managed by lazy.nvim, not Nix
    initLua = builtins.readFile ../nvchad/init.lua;
  };

  home.packages = with pkgs; [
    helix
    tree-sitter
  ];
}
