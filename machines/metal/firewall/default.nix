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
      trustedInterfaces = [ "tailscale0" ];
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
      externalInterface = "enp1s0f0";
      internalInterfaces = [ "enp1s0f3" ];
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
    authKeyFile = config.sops.secrets.tailscale-key.path;
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-routes=10.10.10.150/32" ];
  };

  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      "expand-hosts" = true;
      "domain" = "internal";
      "dhcp-range" = [ "enp1s0f3,10.10.10.2,10.10.10.254,24h" ];
      "local" = [ "/nospawnn.com/" "/internal/" ];
      "address" = [ "/nospawnn.com/10.10.10.150" ];
      "interface" = [ "enp1s0f3" "tailscale0" ];
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
