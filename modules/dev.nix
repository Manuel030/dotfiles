{ pkgs, ... }:

# Language toolchains, cloud/infra CLIs and language servers. 

{
  home.packages = with pkgs; [
    # languages / build
    (python313.withPackages (ps: with ps; [ numpy pytest pylint black isort python-lsp-server pydantic ]))
    poetry
    rye
    uv
    rustc
    rustup
    nodejs_26
    pnpm
    openjdk
    maven
    gnumake
    gcc

    # cloud / infra
    awscli2
    awslogs
    kubectl
    opentofu
    #terraform
    cloudflared
    ngrok

    # agents
    claude-code
    # opencode.packages.${pkgs.stdenv.system}.default
    # antigravity
    agent-browser

    # language servers
    pyright
    typescript-language-server
    nil
    nixpkgs-fmt
    vscode-langservers-extracted
  ];
}
