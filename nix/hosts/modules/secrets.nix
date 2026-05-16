{ config, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    age.generateKey = true;

    secrets = {
      immich = {
        sopsFile = ../../../quadlets/immich/secret.env;
        format = "dotenv";
        path = "/home/services/.config/containers/systemd/immich/.env";
        owner = config.users.users.services.name;
      };
    };
  };
}
