{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:

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
             ./nix/hosts/metal/hv-1 
             home-manager.nixosModules.home-manager
             {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;
               home-manager.extraSpecialArgs = { inherit inputs; };
               home-manager.users.services = ./nix/users/services.nix;
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
              self.formatter.${system}
            ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}

