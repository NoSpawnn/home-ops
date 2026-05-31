{ config, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    age.generateKey = true;

    secrets = {
      "immich.env" = {
        sopsFile = ./immich/secret.env;
        format = "dotenv";
        owner = "services";
      };
      "davis.env" = {
        sopsFile = ./dav/secret.env;
        format = "dotenv";
        owner = "services";
      };
    };
  };
}
