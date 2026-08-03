{ pkgs, unstable, config, ... }:

# Shared baseline: shell, prompt, VCS, and CLI tooling that makes sense on
# every host (laptop and headless-ish Pi alike).

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  nixpkgs.config.allowUnfree = true;
  # workaround from nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  xdg.configFile = {
    "starship.toml".source = makeLink "starship.toml";
  };

  programs = {
    home-manager.enable = true;
    bash = {
      enable = true;
      # Apple ships ancient bash so we need this fix on macOS
      # https://github.com/nix-community/home-manager/issues/3133
      enableCompletion = false;
      bashrcExtra = ''
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
    starship.enable = true;
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    # inspection / navigation
    bat
    btop
    jless
    jq
    md-tui
    ripgrep
    tealdeer
    tree
    yazi

    # containers
    ctop
    dive
    lazydocker

    # misc
    glab
    hyperfine
    nmap
    rclone
  ];

  home.file = {
    ".local/bin" = {
      executable = true;
      source = ../scripts;
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
