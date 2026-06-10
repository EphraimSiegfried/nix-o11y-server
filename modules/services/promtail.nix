{
  flake.modules.nixos.promtail =
    { config, pkgs, ... }:
    {
      users.users.alloy = {
        isSystemUser = true;
        group = "alloy";
        extraGroups = [ "caddy" ];
      };
      users.groups.alloy = {};

      services.alloy = {
        enable = true;
        extraFlags = [ "--stability.level=generally-available" ];
      };

      environment.etc."alloy/config.alloy".text = ''
        local.file_match "caddy_logs" {
          path_targets = [
            {
              "__path__" = "/var/log/caddy/a-*.log",
              "job"      = "caddy",
              "host"     = "${config.networking.hostName}",
            },
          ]
        }

        loki.source.file "caddy" {
          targets    = local.file_match.caddy_logs.targets
          forward_to = [loki.process.caddy.receiver]
        }

        loki.process "caddy" {
          stage.json {
            expressions = {
              level  = "level",
              status = "status",
              method = "request.method",
              uri    = "request.uri",
              ts     = "ts",
            }
          }
          stage.timestamp {
            source = "ts"
            format = "Unix"
          }
          stage.labels {
            values = {
              level  = "",
              status = "",
              method = "",
            }
          }
          forward_to = [loki.write.local.receiver]
        }

        loki.source.journal "systemd" {
          max_age       = "12h"
          relabel_rules = loki.relabel.journal.rules
          labels        = {
            job  = "systemd-journal",
            host = "${config.networking.hostName}",
          }
          forward_to = [loki.write.local.receiver]
        }

        loki.relabel "journal" {
          forward_to = []
          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
        }

        loki.write "local" {
          endpoint {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
          }
        }
      '';
    };
}
