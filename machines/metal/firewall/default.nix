{
  config,
  lib,
  pkgs,
  ...
}:

let
  wanIface = "enp1s0f0";
  lanIface = "enp1s0f3";

  lanGatewayAddress = "10.10.10.1";
  dhcpRange = {
    start = "10.10.10.2";
    end = "10.10.10.254";
  };
in
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
      externalInterface = wanIface;
      internalInterfaces = [ lanIface ];
    };

    interfaces = {
      "${wanIface}".useDHCP = true;

      "${lanIface}".ipv4.addresses = [
        {
          address = lanGatewayAddress;
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
      "dhcp-range" = [ "${lanIface},${dhcpRange.start},${dhcpRange.end},24h" ];
      "local" = [
        "/nospawnn.com/"
        "/internal/"
      ];
      "address" = [ "/nospawnn.com/10.10.10.150" ];
      "interface" = [
        lanIface
        "tailscale0"
      ];
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
