{
  flake.modules.nixos.vpn =
    { config, ... }:
    {
      networking.wireguard.interfaces.wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;

        # public key: 8L3Cwpj1cRznCJ8zzV9//6EWQ20NCGAQWAFUO4bK4h8=
        privateKeyFile = config.sops.secrets."wireguard/private_key".path;

        peers = [
          {
            publicKey = "WjPNjktboq9qwsTHzZDn56eO3JPI1eJxnS+2QjEMTms=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };

      networking.firewall = {
        allowedUDPPorts = [ 51820 ];
        interfaces."wg0".allowedTCPPorts = [
          config.services.prometheus.port
          config.services.loki.configuration.server.http_listen_port
        ];
      };
      sops.secrets."wireguard/private_key" = {
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };
    };
}
