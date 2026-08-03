{
  description = "Home Manager Flake";

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-linux.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = { nixpkgs-darwin, nixpkgs-linux, nixpkgs-unstable, home-manager, ... }:
    let
      mkHome = { system, nixpkgs, module }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [ module ];
        };

      geonosis = mkHome {
        system = "aarch64-darwin";
        nixpkgs = nixpkgs-darwin;
        module = ./hosts/geonosis.nix;
      };

      raspberrypi = mkHome {
        system = "aarch64-linux";
        nixpkgs = nixpkgs-linux;
        module = ./hosts/raspberrypi.nix;
      };
    in
    {
      defaultPackage.aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
      defaultPackage.aarch64-linux = home-manager.defaultPackage.aarch64-linux;

      # `home-manager switch --flake .` picks <user>@<hostname> automatically,
      # so the same command works on every host.
      homeConfigurations = {
        "manuel@geonosis" = geonosis;
        "manuel@raspberrypi" = raspberrypi;
        # back-compat with the previous single-host output name
        "manuel" = geonosis;
      };
    };
}
