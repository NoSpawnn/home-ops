{ ... }:

let
  mkQuadletUser =
    name: attrs:
    {
      programs.home-manager.enable = true;
      home.homeDirectory = "/home/${name}";
      home.username = name;
      home.stateVersion = "25.11";
    }
    // attrs;
in
{
  services = mkQuadletUser "services" {
    services.quadmanix = {
      enable = true;
      quadlets.source = ../quadlets;
      quadlets.extraFiles = [ "Caddyfile" ];
    };
  };
}
