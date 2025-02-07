{
  description = "flake for yourHostNameGoesHere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-flatpak,
    nixvim,
  } @ attrs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.sebastian-laptop-hp = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [./nixos/configuration.nix];
    };

    homeConfigurations."sebastian" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home-manager/home.nix ];
      extraSpecialArgs = {
        inherit nix-flatpak nixvim;
      };
    };
  };
}
