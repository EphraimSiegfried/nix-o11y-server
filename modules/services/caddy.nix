{
  flake.modules.nixos.caddy =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      mkVhost = _name: svc: {
        "${svc.subdomain}.${config.domain}" = {
          extraConfig = ''
            reverse_proxy http://localhost:${toString svc.port}
          '';
        };
      };
      conf = config;
    in
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-4WF7tIx8d6O/Bd0q9GhMch8lS3nlR5N3Zg4ApA3hrKw=";
        };
        email = conf.primaryUser.email;
        globalConfig = ''
          acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          skip_install_trust
        '';
        environmentFile = config.sops.templates."caddy.env".path;
        virtualHosts = lib.mkMerge (lib.mapAttrsToList mkVhost conf.myServices);
      };

      systemd.services.caddy.serviceConfig.Path = [ pkgs.nssTools ];

      sops.secrets."cloudflare/api_token" = {
        owner = config.systemd.services.caddy.serviceConfig.User;
      };
      sops.templates."caddy.env" = {
        owner = config.systemd.services.caddy.serviceConfig.User;
        content = ''
          CLOUDFLARE_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
        '';
      };
    };

  flake.modules.nixos.caddy-vm =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      mkVhost = _name: svc: {
        "${svc.subdomain}.${config.domain}" = {
          extraConfig = ''
            tls internal
            reverse_proxy http://localhost:${toString svc.port}
          '';
        };
      };
    in
    {
      services.caddy = {
        enable = true;
        virtualHosts = lib.mkMerge (lib.mapAttrsToList mkVhost config.myServices);
      };
      systemd.services.caddy.serviceConfig.Path = [ pkgs.nssTools ];
    };
}
