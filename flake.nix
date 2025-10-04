{
  description = "flake for yourHostNameGoesHere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-flatpak,
    nixvim,
    sops-nix,
    stylix,
    ...
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

    homeConfigurations."sebastian@sebastian-laptop-hp" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./home-manager/users/sebastian-gnome.nix];
      extraSpecialArgs = {
        inherit nix-flatpak nixvim sops-nix stylix;
      };
    };

    homeConfigurations."sebastian@sebastian-kde" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./home-manager/users/sebastian-kde.nix];
      extraSpecialArgs = {
        inherit nix-flatpak nixvim sops-nix stylix;
      };
    };
  };
}
