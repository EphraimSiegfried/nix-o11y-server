{
  flake.modules.nixos.matrix =
    { config, ... }:
    {
      myServices.matrix = {
        subdomain = "matrix";
        port = 6167;
      };

      services.matrix-conduit = {
        enable = true;
        settings.global = {
          server_name = "${config.myServices.matrix.subdomain}.${config.domain}";
          address = "::1";
          database_backend = "rocksdb";

          port = config.myServices.matrix.port;

          allow_registration = true;
          registration_token = config.sops.placeholder."matrix/registration_token";
        };
      };

      sops.secrets."matrix/registration_token" = {
        # owner = config.systemd.services.matrix-conduit.serviceConfig.User;
      };

    };
}
