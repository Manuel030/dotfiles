{ pkgs, unstable, config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{

  home.username = "manuel";
  home.homeDirectory = "/Users/manuel";

  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;
  # workaround from nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  xdg.configFile = {
    "Code/User/settings.json".source = makeLink "settings.json";
    "Code/User/keybindings.json".source = makeLink "keybindings.json";
    "helix/config.toml".source = makeLink "helix/config.toml";
    "helix/languages.toml".source = makeLink "helix/languages.toml";
    "helix/themes/default-transparent.toml".source = makeLink "helix/default-transparent.toml";
    "kitty/kitty.conf".source = makeLink "kitty.conf";
    "nvim/lua/settings.lua".source = makeLink "neovim.lua";
    "starship.toml".source = makeLink "starship.toml";
    # tiling window manager for macOs
    "aerospace/aerospace.toml".source = makeLink "aerospace.toml";
  };

  programs = {
    home-manager.enable = true;
    bash = {
      enable = true;
      # Apple ships ancient bash so we need this fix on macOS
      # https://github.com/nix-community/home-manager/issues/3133
      enableCompletion = false;
      bashrcExtra = ''
        export PATH="$HOME/.rye/shims:$PATH"
        export PATH=/opt/homebrew/bin:$PATH

        set -a
        if [ -f "$HOME/Projects/dotfiles/.secrets" ]; then
            source $HOME/Projects/dotfiles/.secrets
        fi;
      '';
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    git = {
      userName = "Manuel Plank";
      userEmail = "manuelenrique.plank@gmail.com";
      enable = true;
      lfs.enable = true;
      ignores = [ ".vscode" ];
      aliases = {
        a = "add";
        c = "commit";
        s = "status";
        fomo = "fetch origin main && git rebase origin/main";
      };
    };
    nix-index.enable = true;
    starship = {
      enable = true;
    };
    zoxide.enable = true;
    neovim = {
      enable = true;
      extraConfig = ''
        luafile ${config.xdg.configHome}/nvim/lua/settings.lua
      '';
    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      bufferline-nvim
      nvim-web-devicons
      catppuccin-nvim
      nvim-tree-lua
      comment-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      cmp-nvim-lsp
      nvim-cmp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      avante-nvim
      diffview-nvim
      git-blame-nvim
      vim-visual-multi
      ];
    };
  };

  home.packages = with pkgs; [
    # gui
    audacity
    google-chrome
    slack
    postman

    # shells and editors
    unstable.vscode
    unstable.zed-editor
    helix
    kitty
    nerd-fonts.jetbrains-mono

    # tools
    lazydocker
    tealdeer
    (python312.withPackages (ps: with ps; [ numpy pytest pylint black isort python-lsp-server pydantic ]))
    rye
    poetry
    uv
    rustup
    nodejs
    pnpm
    kubectl
    gnumake
    baobab
    ngrok
    cloudflared
    scrcpy
    hyperfine
    bat
    dive
    jless
    jq
    tree
    btop
    ctop
    ripgrep
    md-tui
    bruno

    # language servers
    pyright
    nodePackages_latest.typescript-language-server
    nodePackages_latest.svelte-language-server
    nil
    nixpkgs-fmt
    elmPackages.elm-language-server
    vscode-langservers-extracted
  ] ++ 
    (if stdenv.isLinux then
      [ distrobox usbimager heaptrack ] 
    else if stdenv.isDarwin then
      [ unstable.aerospace ]
    else throw "Unknown OS")
  ;

  home.file = {
    ".local/bin" = {
      executable = true;
      source = ./scripts;
      recursive = true;
    };
  };

  home.shellAliases = {
    "ll" = "ls -Fahl";
    "," = ''f() { nix run nixpkgs#"$1" -- "{@:2}" ; }; f'';
    "shell" = ''f() { nix shell $(printf "nixpkgs#%s" "$@") ; }; f'';
    # "system" = ''sudo nixos-rebuild switch --flake ~/.machines#helium'';
    "home" = ''home-manager switch --flake ~/Projects/dotfiles/'';
    "dcu" = ''docker compose up'';
    "dcd" = ''docker compose down'';
    "activity" = "sh ~/.local/bin/gitlab-activity.sh";
  };
}
