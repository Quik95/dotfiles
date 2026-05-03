{
  description = "NixOS and Home Manager configurations for sebastian's laptops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lazyvim.url = "github:pfassina/lazyvim-nix/1d4fe049ef1ccfc2b0ad2ce2b01fb8f92c3e51ef";
    lazyvim.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";
    nix-jetbrains-plugins.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-flatpak,
    lazyvim,
    sops-nix,
    stylix,
    nix-jetbrains-plugins,
    llm-agents,
    nur,
    plasma-manager,
    ...
  } @ attrs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [nur.overlays.default];
    };
  in {
    nixosConfigurations.sebastian-laptop-hp = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        ./modules/nixos.nix
        ./nixos/hosts/sebastian-laptop-hp/configuration.nix
      ];
    };

    nixosConfigurations.sebastian-laptop-legion = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        ./modules/nixos.nix
        ./nixos/hosts/sebastian-laptop-legion/configuration.nix
      ];
    };

    homeConfigurations."sebastian@sebastian-laptop-hp" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-manager/home.nix
        ./modules/home-standalone.nix
        ./home-manager/hosts/sebastian-laptop-hp.nix
      ];
      extraSpecialArgs = {
        inherit nix-flatpak lazyvim sops-nix stylix nix-jetbrains-plugins llm-agents plasma-manager;
        hostname = "sebastian-laptop-hp";
      };
    };

    homeConfigurations."sebastian@sebastian-laptop-legion" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-manager/home.nix
        ./modules/home-standalone.nix
        ./home-manager/hosts/sebastian-laptop-legion.nix
      ];
      extraSpecialArgs = {
        inherit nix-flatpak lazyvim sops-nix stylix nix-jetbrains-plugins llm-agents plasma-manager;
        hostname = "sebastian-laptop-legion";
      };
    };

    formatter.${system} = pkgs.alejandra;
  };
}
