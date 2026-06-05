{ ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    age.generateKey = true;

    secrets = {
      "tailscale-key" = {
        sopsFile = ./tailscale_key.secret;
        format = "binary";
      };
      "cf-creds" = {
        sopsFile = ./cf_creds.env;
        format = "dotenv";
        owner = "net";
      };
    };
  };
}
