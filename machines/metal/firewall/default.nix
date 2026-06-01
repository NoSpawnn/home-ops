{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./secrets/secrets.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "firewall";
    domain = "internal";

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [
        53
        67
        68
      ];
    };

    nat = {
      enable = true;
      internalInterfaces = [ "enp1s0f3" ];
      externalInterface = "enp1s0f0";
    };

    interfaces = {
      "enp1s0f0".useDHCP = true;

      "enp1s0f3".ipv4.addresses = [
        {
          address = "10.10.10.1";
          prefixLength = 24;
        }
      ];
    };

    useHostResolvConf = false;
  };

  time.timeZone = "Europe/London";

  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7FOHMLoU4IPA6f569wESim6dD0CMQv35wxm7lmZyTZ Main"
      ];
    };
  };

  environment.variables = {
    "EDITOR" = "vim";
  };

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
    authKeyFile = "/run/secrets/tailscale_key";
  };

  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      "dhcp-range" = [ "enp1s0f3,10.10.10.2,10.10.10.254,24h" ];
      "interface" = "enp1s0f3";
      "server" = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";
}
