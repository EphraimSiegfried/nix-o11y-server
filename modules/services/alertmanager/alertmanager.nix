{
  flake.modules.nixos.alertmanager =
    { config, ... }:
    let
      port = 9093;
      subdomain = "am";
    in
    {
      services.prometheus = {
        alertmanager = {
          enable = true;
          port = port;
          webExternalUrl = "https://${subdomain}.${config.domain}";
          openFirewall = true;
          checkConfig = true;
          # Docs: https://prometheus.io/docs/alerting/latest/configuration/
          configuration = {
            route = {
              # The labels by which incoming alerts are grouped together. For example,
              # multiple alerts coming in for cluster=A and alertname=LatencyHigh would
              # be batched into a single group.
              group_by = [ "..." ];
              # How long to initially wait to send a notification for a group
              # of alerts. Allows to wait for an inhibiting alert to arrive or collect
              # more initial alerts for the same group.
              group_wait = "30s";
              # How long to wait before sending a notification about new alerts that
              # are added to a group of alerts for which an initial notification has
              # already been sent.
              group_interval = "5m";
              # How long to wait before sending a notification again if it has already
              # been sent successfully for an alert.
              repeat_interval = "4h";
              receiver = "default";
            };
            receivers = [
              {
                name = "default";
                webhook_configs = [
                  {
                    url = "http://127.0.0.1:${toString config.services.matrix-alertmanager.port}/alerts";
                    http_config.basic_auth = {
                      username = "alertmanager";
                      password_file = config.sops.secrets."alertmanager/secret".path;
                    };
                  }
                ];
              }
            ];
          };
        };
        ruleFiles = [ ./alerts.yml ];
        alertmanagers = [
          {
            static_configs = [
              {
                targets = [
                  "127.0.0.1:${toString port}"
                ];
              }
            ];
          }
        ];
      };
      services.matrix-alertmanager = {
        enable = true;
        homeserverUrl = "https://${config.myServices.matrix.subdomain}.${config.domain}";
        port = 9111;
        matrixUser = "@bot:${config.myServices.matrix.subdomain}.${config.domain}";
        tokenFile = config.sops.secrets."matrix/access_token".path;
        secretFile = config.sops.secrets."alertmanager/secret".path;
        matrixRooms = [
          {
            roomId = "!2_UFBIIma_BJ9AEyrdDrzGOgAeiHeG2lIbSTjQy9e8Q";
            receivers = [ config.services.prometheus.alertmanager.configuration.route.receiver ];
          }
        ];
      };

      sops.secrets."matrix/room_id" = {
        mode = "0444";
      };
      sops.secrets."alertmanager/secret" = {
        mode = "0444";
      };
      sops.secrets."matrix/access_token" = {
        # TODO: change
        mode = "0444";
      };

    };
}
