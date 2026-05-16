{
  config,
  lib,
  pkgs,
  ...
}:

let
  quadletsRoot = ../../quadlets;

  listFiles =
    dir:
    let
      entries = builtins.readDir dir;
      paths = lib.mapAttrsToList (
        name: type:
        let
          full = "${dir}/${name}";
        in
        if type == "directory" then listFiles full else full
      ) entries;
    in
    lib.flatten paths;

  # find and create all %h/localappdata paths
  quadletFiles = listFiles quadletsRoot;
  volumes = lib.concatMap (
    content: builtins.filter (line: lib.hasPrefix "Volume=" line) (lib.splitString "\n" content)
  ) (map builtins.readFile quadletFiles);
  localappdataVolumes = builtins.filter (v: lib.hasInfix "localappdata" v) volumes;
  localappdataHostPaths = map (
    v:
    let
      hostPath = builtins.head (lib.splitString ":" (lib.removePrefix "Volume=" v));
    in
    lib.replaceStrings [ "%h" ] [ config.home.homeDirectory ] hostPath
  ) localappdataVolumes;
in
{
  home.username = "services";
  home.homeDirectory = "/home/services";

  home.file = {
    ".config/containers/systemd" = {
      source = quadletsRoot;
      recursive = true;
      force = true;
    };
  };
  systemd.user.tmpfiles.rules =
    (map (p: "d ${p} 0700 ${config.home.username} users -") localappdataHostPaths);

  #sops = {
  #  secrets.immich = {
  #    sopsFile = "${quadletsRoot}/immich/secret.env";
  #    path = "${config.home.homeDirectory}/.config/containers/systemd/immich/.env";
  #    format = "dotenv";
  #  };
  #};

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
