{ ... }:

let
  mkQuadletUser =
    name: attrs:
    {
      programs.home-manager.enable = true;
      home.homeDirectory = "/home/${name}";
      home.username = name;
      home.stateVersion = "25.11";

      # TODO: sops-nix in here somehow...
      # the main issue is the chicken and egg problem of creating an age key for the user without actually building the system for the first time since that will fail because we can't decrypt the secrets. bleh
      # %t in units can be used alongside %r here for runtime dir
      # sops = {
      #   #age.keyFile = "/home/user/.age-key.txt"; # must have no password!
      #   #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
      #   secrets."${name}-env" = {
      #     # sopsFile = secretSource; # take another arg, or maybe list of, secret sauces?
      #     path = "%r/.env";
      #   };
      # };
    }
    // attrs;
in
{
  # TODO: move this to system quadlets?
  net = mkQuadletUser "net" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets/net;
    };
  };

  git = mkQuadletUser "git" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets/git;
    };
  };

  auth = mkQuadletUser "auth" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets/auth;
    };
  };

  immich = mkQuadletUser "immich" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets/immich;
    };
  };

  dav = mkQuadletUser "dav" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets/dav;
      quadlets.extraFiles = [ "Caddyfile" ];
    };
  };

  services = mkQuadletUser "services" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets/general;
    };
  };
}
