{ pkgs, unstable, config,  ... }:

let
  dotfiles = "${config.home.homeDirectory}/Projects/dotfiles";
  makeLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{

  home.username = "manuel";
  home.homeDirectory = "/Users/manuel";

  home.stateVersion = "24.11";

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
      nvim-cmp
      avante-nvim
      ];
    };
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
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # tools
    lazydocker
    tealdeer
    (python312.withPackages (ps: with ps; [ numpy pytest pylint black isort python-lsp-server ]))
    rye
    poetry
    uv
    kubectl
    gnumake
    baobab
    ngrok
    scrcpy
    hyperfine
    bat
    dive
    jless
    jq
    tree
    btop
    ctop

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
      [ distrobox usbimager heaptrack unstable.code-cursor ] 
    else if stdenv.isDarwin then
      [ unstable.aerospace ]
    else throw "Unknown OS")
  ;

  home.file = {
    ".local/bin/gitlab-activity" = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        if [ -z "$GITLAB_TOKEN" ]; 
        then
          echo "No GITLAB_TOKEN provided"
          exit 1;
        fi;
        read -p "Enter date difference to today: " DAYS
        AFTER_DATE=$(date -v-"$(($DAYS+1))"d +%Y-%m-%d)
        if [ $DAYS == 1 ]
        then
          BEFORE_DATE=$(date +%Y-%m-%d);
        elif [ $DAYS == 0 ]
        then
          BEFORE_DATE=$(date -v+1d +%Y-%m-%d);
        else
          BEFORE_DATE=$(date -v-"$(($DAYS-1))"d +%Y-%m-%d);
        fi;
        echo "Querying activity after $AFTER_DATE and before $BEFORE_DATE"
        GITLAB_USER="manuelpland"
        COMMIT_LOG=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/users/$GITLAB_USER/events?after=$AFTER_DATE&before=$BEFORE_DATE&per_page=100" \
          | jq '.[] | { action: .action_name, description: (if .target_title != null then .target_title elif .push_data != null then .push_data.commit_title elif .note != null then .note.body else "No title" end), branch: (if .action_name == "pushed to" then .push_data.ref else "no code change" end)}')

        echo "Your commit log"
        echo $COMMIT_LOG | jq

        PROMPT="Describe the programmers work based on the commit log in a concise manner. Only do the task without any introductions and write from the programmers perspective. Dont do any formatting. $COMMIT_LOG"

        PAYLOAD=$(jq -n \
          --arg model "llama3-8b-8192" \
          --arg content "$PROMPT" \
          '{
            model: $model,
            messages: [
              {
                role: "user",
                content: $content
              }
            ]
          }'
        )

        echo "Your summary"
        curl https://api.groq.com/openai/v1/chat/completions -s \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer $GROQ_API_KEY" \
          -d "$PAYLOAD" | jq .choices[0].message.content
      '';
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
    "activity" = "~/.local/bin/gitlab-activity";
  };
}
