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

      localDomain = "internal";

      mkNixosSystem =
        let
          adminUser = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            initialPassword = "changeme";
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7FOHMLoU4IPA6f569wESim6dD0CMQv35wxm7lmZyTZ Main"
            ];
          };

          specialArgs = {
            inherit localDomain;
            flake-inputs = inputs;
          };

          baseHomeManagerConfig = {
            home-manager.sharedModules = [
              quadmanix.homeManagerModules.quadmanix
              sops-nix.homeManagerModules.sops
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
          };

          baseNixSettings = {
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            nix.gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
            nix.optimise = {
              automatic = true;
              dates = "weekly";
            };
          };
        in
        {
          machineConfig,
          baseModules ? [
            home-manager.nixosModules.home-manager
            baseHomeManagerConfig
            quadmanix.nixosModules.quadmanix
            sops-nix.nixosModules.sops
          ],
          system ? "x86_64-linux",
        }:
        lib.nixosSystem {
          inherit specialArgs system;
          modules = baseModules ++ [
            machineConfig
            baseNixSettings
            { users.users.admin = adminUser; }
          ];

        };

      forEachSupportedSystem =
        f:
        lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      nixosConfigurations = {
        hv-1 = mkNixosSystem {
          machineConfig = ./machines/metal/hv-1;
        };

        firewall = mkNixosSystem {
          machineConfig = ./machines/metal/firewall;
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
