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
  in {
    nixosConfigurations = {
      sebastian-laptop-hp = let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
              in
        nixpkgs.lib.nixosSystem {
          inherit system;
                    modules = [
            ./nixos/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sebastian = import ./home-manager/home.nix;

              home-manager.extraSpecialArgs = {
                inherit pkgs nix-flatpak nixvim;
              };
            }
          ];
        };
    };
  };
}
