{
  description = "flake for yourHostNameGoesHere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-flatpak,
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

        unstablePkgs = import nixpkgs-unstable {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs;
            unstable = unstablePkgs;
          };
          modules = [
            ./nixos/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sebastian = import ./home-manager/home.nix;

              home-manager.extraSpecialArgs = {
                inherit pkgs nix-flatpak;
                unstable = unstablePkgs;
              };
            }
          ];
        };
    };
  };
}
