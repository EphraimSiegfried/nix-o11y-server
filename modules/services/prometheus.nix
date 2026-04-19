{
  flake.modules.nixos.prometheus =
    { config, lib, ... }:
    {
      services.prometheus = {
        enable = true;
        port = 9001;
        extraFlags = [ "--web.enable-remote-write-receiver" ];
        exporters.node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
        globalConfig.scrape_interval = "15s";
        scrapeConfigs = [
          {
            job_name = "node_exporter";
            static_configs = [ { targets = [ "127.0.0.1:9002" ]; } ];
            relabel_configs = [
              {
                target_label = "instance";
                replacement = config.networking.hostName;
              }
            ];
          }
          {
            job_name = "caddy";
            static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
          }
        ];
      };
    };
}
