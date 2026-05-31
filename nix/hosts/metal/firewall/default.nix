{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "firewall";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7FOHMLoU4IPA6f569wESim6dD0CMQv35wxm7lmZyTZ Main" ];
    };
  };  

  environment.variables = { "EDITOR" = "vim"; };
  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
    dnsutils
    wget
  ];

  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
    };
  };

  system.stateVersion = "25.11";
}

