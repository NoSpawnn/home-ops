{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    quadmanix.url = "github:NoSpawnn/quadmanix";
    quadmanix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      quadmanix,
      ...
    }@inputs:

    let
      inherit (nixpkgs) lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      nixosConfigurations = {
        hv-1 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.flake-inputs = inputs;
          modules = [
            ./machines/metal/hv-1
            sops-nix.nixosModules.sops
            quadmanix.nixosModules.quadmanix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                quadmanix.homeManagerModules.quadmanix
                sops-nix.homeManagerModules.sops
              ];
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users = import ./machines/metal/hv-1/users/services.nix { };
            }
          ];
        };
      };

      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixd
              nil
              age
              sops
              ssh-to-age
              lazygit
              podlet
              just
              self.formatter.${system}
            ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
