{
  description = "NixOS and Home Manager configurations for sebastian's laptops";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix/1d4fe049ef1ccfc2b0ad2ce2b01fb8f92c3e51ef";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "llm-agents/systems";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        flake-parts.follows = "llm-agents/flake-parts";
      };
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    nix-jetbrains-plugins = {
      url = "github:nix-community/nix-jetbrains-plugins";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "llm-agents/systems";
      };
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "llm-agents/flake-parts";
      };
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-index-database,
    home-manager,
    sops-nix,
    nur,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [nur.overlays.default];
    };
    hosts = {
      sebastian-laptop-legion = {
        nixosModule = ./nixos/hosts/sebastian-laptop-legion/configuration.nix;
        homeModule = ./home-manager/hosts/sebastian-laptop-legion.nix;
      };
    };

    mkNixos = _: host:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          nix-index-database.nixosModules.default
          ./modules/nixos.nix
          host.nixosModule
        ];
      };

    mkHome = hostname: host:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/home.nix
          ./modules/home-standalone.nix
          host.homeModule
        ];
        extraSpecialArgs = {
          inherit inputs hostname;
        };
      };
  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs mkNixos hosts;
    homeConfigurations =
      nixpkgs.lib.mapAttrs' (
        hostname: host: nixpkgs.lib.nameValuePair "sebastian@${hostname}" (mkHome hostname host)
      )
      hosts;

    checks.${system} =
      nixpkgs.lib.mapAttrs' (
        hostname: _:
          nixpkgs.lib.nameValuePair "home-manager-${nixpkgs.lib.removePrefix "sebastian-laptop-" hostname}"
          self.homeConfigurations."sebastian@${hostname}".activationPackage
      )
      hosts
      // {
        formatting = pkgs.runCommand "check-formatting" {} ''
          ${pkgs.alejandra}/bin/alejandra --check --quiet ${self}
          touch "$out"
        '';
      };

    formatter.${system} = pkgs.alejandra;
  };
}
