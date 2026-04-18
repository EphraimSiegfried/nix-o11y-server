{
  flake.modules.nixos.promtail =
    { config, ... }:
    {
      users.users.promtail.extraGroups = [ "caddy" ];

      services.promtail = {
        enable = true;
        configuration = {
          server = {
            http_listen_port = 3031;
            grpc_listen_port = 0;
          };
          positions = {
            filename = "/tmp/positions.yaml";
          };
          clients = [
            {
              url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
            }
          ];
          scrape_configs = [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  host = config.networking.hostName;
                };
              };
              relabel_configs = [
                {
                  source_labels = [ "__journal__systemd_unit" ];
                  target_label = "unit";
                }
              ];
            }
            {
              job_name = "caddy";
              static_configs = [
                {
                  targets = [ "localhost" ];
                  labels = {
                    job = "caddy";
                    host = config.networking.hostName;
                    __path__ = "/var/log/caddy/a-*.log";
                  };
                }
              ];
              pipeline_stages = [
                {
                  json = {
                    expressions = {
                      level = "level";
                      status = "status";
                      method = "request.method";
                      uri = "request.uri";
                      ts = "ts";
                    };
                  };
                }
                {
                  timestamp = {
                    source = "ts";
                    format = "Unix";
                  };
                }
                {
                  labels = {
                    level = "";
                    status = "";
                    method = "";
                  };
                }
              ];
            }
          ];
        };
      };
    };
}
