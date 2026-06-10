{
  flake.modules.nixos.matrix =
    { config, ... }:
    {
      webServices.matrix = {
        subdomain = "matrix";
        port = 6167;
      };

      services.matrix-conduit = {
        enable = true;
        settings.global = {
          server_name = "${config.webServices.matrix.subdomain}.${config.domain}";
          address = "::1";
          database_backend = "rocksdb";

          port = config.webServices.matrix.port;

          allow_registration = true;
        };
        secretFile = config.sops.templates."conduit.env".path;
      };
      sops.templates."conduit.env" = {
        # conduit uses dynamicuser which makes it hard to give it ownership to the secret
        mode = "0444";
        content = ''
          CONDUIT_REGISTRATION_TOKEN=${config.sops.placeholder."matrix/registration_token"}
        '';
      };

      sops.secrets."matrix/registration_token" = { };

    };
}

# Access token created with:
# curl -XPOST 'https://your.homeserver/_matrix/client/v3/login' \
#   -H 'Content-Type: application/json' \
#   -d '{
#     "type": "m.login.password",
#     "identifier": {
#       "type": "m.id.user",
#       "user": "yourusername"
#     },
#     "password": "yourpassword",
#     "device_id": "MY_BOT",
#     "initial_device_display_name": "My Bot"
#   }'
