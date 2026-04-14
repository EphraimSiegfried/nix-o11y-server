{
  flake.modules.nixos.gatus =
    { config, ... }:
    let
      main_domain = "qew.ch";
      default_interval = "1m";
      matrix_url = "https://${config.myServices.matrix.subdomain}.${config.domain}";
    in
    {
      myServices.gatus = {
        subdomain = "health";
        port = 9192;
      };
      services.gatus = {
        enable = true;
        openFirewall = true;
        configFile = config.sops.templates."gatus.yaml".path;
        settings = {
          web.port = config.myServices.gatus.port;

          alerting.matrix = {
            server-url = matrix_url;
            default-alert = {
              send-on-resolved = true;
              failure-threshold = 3;
              success-threshold = 5;
            };
          };
          endpoints = [
            {
              name = "Jellyfin";
              url = "https://jelly.${main_domain}/health";
              group = "Media";
              interval = default_interval;
              conditions = [
                "[STATUS] == 200"
                "[BODY] == Healthy"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [ { type = "matrix"; } ];
            }
            {
              name = "Jellyseerr";
              url = "https://js.${main_domain}";
              interval = default_interval;
              group = "Media";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [ { type = "matrix"; } ];
            }
            {
              name = "Sonarr";
              url = "https://sonarr.${main_domain}/ping";
              interval = default_interval;
              group = "Media";
              conditions = [
                "[STATUS] == 200"
                "[BODY].status == OK"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Radarr";
              url = "https://radarr.${main_domain}/ping";
              interval = default_interval;
              group = "Media";
              conditions = [
                "[STATUS] == 200"
                "[BODY].status == OK"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Prowlarr";
              url = "https://prowlarr.${main_domain}/ping";
              interval = default_interval;
              group = "Media";
              conditions = [
                "[STATUS] == 200"
                "[BODY].status == OK"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Bazarr";
              url = "https://bazarr.${main_domain}";
              interval = default_interval;
              group = "Media";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Paperless";
              url = "https://paperless.${main_domain}";
              interval = default_interval;
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Nextcloud";
              url = "https://cloud.${main_domain}";
              interval = default_interval;
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Grafana";
              url = "https://grafana.${main_domain}/api/health";
              interval = default_interval;
              conditions = [
                "[STATUS] == 200"
                "[BODY].database == ok"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [ { type = "matrix"; } ];
            }
            {
              name = "Ephraim's Blog";
              url = "https://ephraimsiegfried.ch";
              interval = "10m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
              alerts = [ { type = "matrix"; } ];
            }
          ];
        };
      };
      sops.secrets."matrix/access_token" = { };
      sops.secrets."matrix/room_id" = { };
      sops.templates."gatus.yaml" = {
        mode = "0444";
        content = builtins.toJSON (
          config.services.gatus.settings
          // {
            alerting.matrix = config.services.gatus.settings.alerting.matrix // {
              access-token = config.sops.placeholder."matrix/access_token";
              internal-room-id = config.sops.placeholder."matrix/room_id";
            };
          }
        );
      };
    };
}
