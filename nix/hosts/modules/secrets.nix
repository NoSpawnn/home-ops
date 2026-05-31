{ config, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    age.generateKey = true;

    # TODO: this isn't sustainable...
    secrets = {
      "immich.env" = {
        sopsFile = ../../../quadlets/immich/secret.env;
        format = "dotenv";
        owner = "services";
      };
      "davis.env" = {
        sopsFile = ../../../quadlets/dav/secret.env;
        format = "dotenv";
        owner = "services";
      };
    };
  };
}
