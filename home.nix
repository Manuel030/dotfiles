{ pkgs, unstable, config,  ... }:

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{

  home.username = "manuel";
  home.homeDirectory = "/Users/manuel";

  home.stateVersion = "24.05";

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
        fomo = "fetch origin main && git rebase origin/main";
      };
    };
    nix-index.enable = true;
    starship = {
      enable = true;
      # settings = {
      #   username.show_always = true;
      #   username.format = "[$user](bold red) ";
      #   hostname.ssh_only = false;
      #   hostname.format = "at [$hostname](bold blue) ";
      #   directory.format = "in [$path]($style)[$read_only]($read_only_style) ";
      #   git_branch.format = "on [$branch](bold green) ";
      #   character.format = "> ";
      # };
    };
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    # gui
    audacity
    google-chrome
    slack

    # shells and editors
    vscode
    helix
    kitty

    # tools
    lazydocker
    tealdeer
    (python312.withPackages (ps: with ps; [ numpy pytest pylint black isort python-lsp-server ]))
    rye
    unstable.uv
    kubectl
    gnumake
    baobab
    ngrok
    scrcpy
    hyperfine
    bat
    dive
    jless
    nixpkgs-fmt
    tree
    btop

    # language servers
    nodePackages_latest.typescript-language-server
    nodePackages_latest.svelte-language-server
    nil
    elmPackages.elm-language-server
    vscode-langservers-extracted
  ] ++ 
    (if stdenv.isLinux then
      [ distrobox usbimager heaptrack unstable.code-cursor ] 
    else if stdenv.isDarwin then
      [ unstable.aerospace ]
    else throw "Unknown OS")
  ;

  home.shellAliases = {
    "ll" = "ls -Fahl";
    "," = ''f() { nix run nixpkgs#"$1" -- "{@:2}" ; }; f'';
    "shell" = ''f() { nix shell $(printf "nixpkgs#%s" "$@") ; }; f'';
    # "system" = ''sudo nixos-rebuild switch --flake ~/.machines#helium'';
    "home" = ''home-manager switch --flake ~/Projects/dotfiles/'';
    "dcu" = ''docker compose up'';
    "dcd" = ''docker compose down'';
  };
}
