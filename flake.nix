{
  description = "NixOS and Home Manager configurations for sebastian's laptops";

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

    nix-jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";
    nix-jetbrains-plugins.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-flatpak,
    nixvim,
    sops-nix,
    stylix,
    nix-jetbrains-plugins,
    llm-agents,
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
      modules = [
        sops-nix.nixosModules.sops
        ./nixos/hosts/sebastian-laptop-hp/configuration.nix
      ];
    };

    nixosConfigurations.sebastian-laptop-loq = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        ./nixos/hosts/sebastian-laptop-loq/configuration.nix
      ];
    };

    nixosConfigurations.sebastian-laptop-legion = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        ./nixos/hosts/sebastian-laptop-legion/configuration.nix
      ];
    };

    homeConfigurations."sebastian@sebastian-laptop-hp" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-manager/home.nix
        ./home-manager/hosts/sebastian-laptop-hp.nix
      ];
      extraSpecialArgs = {
        inherit nix-flatpak nixvim sops-nix stylix nix-jetbrains-plugins llm-agents;
        hostname = "sebastian-laptop-hp";
      };
    };

    homeConfigurations."sebastian@sebastian-laptop-loq" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-manager/home.nix
        ./home-manager/hosts/sebastian-laptop-loq.nix
      ];
      extraSpecialArgs = {
        inherit nix-flatpak nixvim sops-nix stylix nix-jetbrains-plugins llm-agents;
        hostname = "sebastian-laptop-loq";
      };
    };

    homeConfigurations."sebastian@sebastian-laptop-legion" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home-manager/home.nix
        ./home-manager/hosts/sebastian-laptop-legion.nix
      ];
      extraSpecialArgs = {
        inherit nix-flatpak nixvim sops-nix stylix nix-jetbrains-plugins llm-agents;
        hostname = "sebastian-laptop-legion";
      };
    };

    formatter.${system} = pkgs.alejandra;
  };
}
