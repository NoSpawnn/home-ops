{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./quadlets/secrets.nix
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.ip_unprivileged_port_start" = 80; };

  networking.hostName = "hv-1";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 222 ];
  };
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  services.nfs.idmapd.settings = {
    General = { Domain = "internal"; };
    Mapping = {
      Nobody-User = "nobody"; 
      Nobody-Group = "nogroup"; 
    };
  };

  fileSystems = {
    "/mnt/nfs/appdata" = {
      device = "truenas.internal:/mnt/tank/appdata";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "hard" "noatime" "rw" "defaults" ];
    };
    "/mnt/nfs/gallery" = {
      device = "truenas.internal:/mnt/tank/gallery";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "hard" "noatime" "rw" "defaults" ];
    };
    "/mnt/nfs/git" = {
      device = "truenas.internal:/mnt/tank/git";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "hard" "noatime" "rw" "defaults" ];
    };
    "/mnt/nfs/media" = {
      device = "truenas.internal:/mnt/tank/media";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "hard" "noatime" "rw" "defaults" ];
    };
    "/mnt/nfs/vault" = {
      device = "truenas.internal:/mnt/tank/vault";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "hard" "noatime" "rw" "defaults" ];
    };
  };

  environment.variables = { "EDITOR" = "vim"; };
  environment.systemPackages = with pkgs; [
    vim
    tmux
    git
    dnsutils
    wget
    borgbackup
  ];

  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
  };


  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
    };
  };

  system.stateVersion = "25.11";
}

