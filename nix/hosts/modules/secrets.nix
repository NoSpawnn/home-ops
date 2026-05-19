{ config, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    age.generateKey = true;

    # TODO: this isn't sustainable...
    secrets = {
      immich = {
        sopsFile = ../../../quadlets/immich/secret.env;
        format = "dotenv";
        path = "/home/services/.config/containers/systemd/immich/.env";
        owner = config.users.users.services.name;
      };
      davis = {
        sopsFile = ../../../quadlets/davis/secret.env;
        format = "dotenv";
        path = "/home/services/.config/containers/systemd/davis/.env";
        owner = config.users.users.services.name;
      };
    };
  };
}
