{ unstable, config, ... }:

# macOS-specific bits: tiling WM and the PATH entries for tooling installed
# outside Nix (Homebrew, rye shims).

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # tiling window manager for macOS
  xdg.configFile."aerospace/aerospace.toml".source = makeLink "aerospace.toml";

  programs.bash.bashrcExtra = ''
    export PATH="$HOME/.rye/shims:$PATH"
    export PATH=/opt/homebrew/bin:$PATH
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
  '';

  home.packages = [ unstable.aerospace ];
}
