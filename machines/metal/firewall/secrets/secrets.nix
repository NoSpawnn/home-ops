{ ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    age.generateKey = true;

    secrets = {
      "tailscale_key" = {
        sopsFile = ./tailscale_key.secret;
        format = "binary";
      };
    };
  };
}
