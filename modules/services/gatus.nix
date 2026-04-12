{ config, ... }:
{
  myServices.gatus = {
    subdomain = "health";
    port = 9192;
  };

  flake.modules.nixos.gatus =
    let
      main_domain = "qew.ch";
      default_interval = "2m";
    in
    {
      services.gatus = {
        enable = true;
        openFirewall = true;
        settings = {
          web.port = config.myServices.gatus.port;
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
            }
            {
              name = "Ephraim's Blog";
              url = "https://ephraimsiegfried.ch";
              interval = "10m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
            }
          ];
        };
      };
    };
}
