{ pkgs, unstable, config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{

  home.username = "manuel";
  home.homeDirectory = "/Users/manuel";

  home.stateVersion = "25.11";

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
    "nvim".source = makeLink "nvchad";
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
        export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
        export PATH="$HOME/.local/bin:$PATH"

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
      package = unstable.direnv;
      nix-direnv.enable = true;
    };
    git = {
      settings = {
        user.name = "Manuel Plank";
        user.email = "manuelenrique.plank@gmail.com";
        aliases = {
          a = "add";
          c = "commit";
          s = "status";
          fomo = "fetch origin main && git rebase origin/main";
        };
      };
      enable = true;
      lfs.enable = true;
      ignores = [ ".vscode" ];
    };
    nix-index.enable = true;
    starship = {
      enable = true;
    };
    zoxide.enable = true;
    neovim = {
      enable = true;
      # NvChad config is symlinked via xdg.configFile."nvim"
      # Plugins are managed by lazy.nvim, not Nix
    };
  };

  home.packages = with pkgs; [
    # gui
    audacity
    google-chrome
    brave
    unstable.slack
    postman
    obsidian

    # shells and editors
    vscode
    helix
    kitty
    nerd-fonts.jetbrains-mono
    claude-code
    # opencode.packages.${pkgs.stdenv.system}.default
    # antigravity

    # tools
    lazydocker
    tealdeer
    (python313.withPackages (ps: with ps; [ numpy pytest pylint black isort python-lsp-server pydantic ]))
    poetry
    rye
    uv
    rustc
    rustup
    nodejs
    pnpm
    kubectl
    gnumake
    maven
    tree-sitter
    gcc
    baobab
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
    yazi
    awscli2
    awslogs
    glab
    rclone
    #terraform
    opentofu
    openjdk

    # networking
    nmap
    ngrok
    cloudflared

    # language servers
    pyright
    nodePackages_latest.typescript-language-server
    nil
    nixpkgs-fmt
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
