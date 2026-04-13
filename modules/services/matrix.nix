{ config, ... }:
let
  conf = config;
in
{

  myServices.matrix = {
    subdomain = "matrix";
    port = 6167;
  };
  flake.modules.nixos.matrix =
    { config, ... }:
    {

      services.matrix-conduit = {
        enable = true;
        settings.global = {
          server_name = "${conf.myServices.matrix.subdomain}.${conf.domain}";
          address = "::1";
          database_backend = "rocksdb";

          port = conf.myServices.matrix.port;

          allow_registration = true;
          registration_token = config.sops.placeholder."matrix/registration_token";
        };
      };

      sops.secrets."matrix/registration_token" = {
        # owner = config.systemd.services.matrix-conduit.serviceConfig.User;
      };

    };
}
