{
  flake.modules.nixos.grafana =
    { config, ... }:
    {
      myServices.grafana = {
        subdomain = "o11y";
        port = 9182;
      };

      services.grafana = {
        enable = true;
        settings = {
          server = {
            domain = "${config.myServices.grafana.subdomain}.${config.domain}";
            http_port = config.myServices.grafana.port;
            addr = "127.0.0.1";
          };
          security = {
            admin_user = config.primaryUser.username;
            admin_email = config.primaryUser.email;
            admin_password = "$__file{${config.sops.secrets."admin-pw".path}}";
          };
        };

        provision = {
          enable = true;
          datasources = {
            settings = {
              datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  uid = "prometheusdatasource";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                  isDefault = true;
                }
                # {
                #   name = "Loki";
                #   type = "loki";
                #   access = "proxy";
                #   url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
                # }
              ];
            };
          };
          dashboards.settings = {
            providers = [
              {
                name = "Node Exporter";
                options.path = ./dashboards/node-exporter-full.json;
              }
            ];
          };
        };
      };

      sops.secrets."admin-pw" = {
        owner = "grafana";
      };
    };
}
