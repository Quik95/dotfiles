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

    omp = {
      url = "github:can1357/oh-my-pi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "llm-agents/flake-parts";
      };
    };

    neko-rs = {
      url = "github:Quik95/neko-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kde-ai-usage = {
      url = "github:Muddyblack/kde-ai-usage/v2.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    syspeek = {
      url = "github:prassamin/SysPeek/v2.0.0";
      flake = false;
    };

    gnome-claude-codex-usage = {
      url = "github:IanBraga96/gnome-claude-codex-usage/7c1ed28c51e224ae9cb5130c054a176978172f07";
      flake = false;
    };

    makiconf = {
      url = "github:tontinton/makiconf";
      flake = false;
    };

    typst-skills = {
      url = "github:apcamargo/typst-skills";
      flake = false;
    };

    picard-plugins = {
      url = "github:metabrainz/picard-plugins";
      flake = false;
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

        actionlint =
          pkgs.runCommand "check-actionlint" {
            nativeBuildInputs = [pkgs.actionlint pkgs.shellcheck];
          } ''
            actionlint -color ${self}/.github/workflows/*.yml
            touch "$out"
          '';

        zizmor =
          pkgs.runCommand "check-zizmor" {
            nativeBuildInputs = [pkgs.zizmor];
          } ''
            zizmor --offline --persona=regular --no-progress ${self}/.github/workflows
            touch "$out"
          '';
      };

    formatter.${system} = pkgs.alejandra;
  };
}
