{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.deploy.nodes.o11y = {
    hostname = "o11y";
    sshUser = "root";
    remoteBuild = true;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.o11y;
    };
  };

  flake.checks = builtins.mapAttrs (
    system: deployLib: deployLib.deployChecks inputs.self.deploy
  ) inputs.deploy-rs.lib;

  flake.nixosConfigurations =
    let
      main_modules = with inputs.self.modules.nixos; [
        inputs.srvos.nixosModules.server
        user
        gatus
        matrix
        settings
        prometheus
        grafana
        promtail
        loki
        alertmanager
        networking
        vpn
        secrets
      ];
    in
    {
      o11y = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          with inputs.self.modules.nixos;
          main_modules
          ++ [
            disk
            caddy
            {
              system.stateVersion = "25.11";
              networking.hostName = "o11y";
            }
          ];
      };

      vm = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =
          with inputs.self.modules.nixos;
          main_modules
          ++ [
            vm
            caddy-vm
            {
              domain = inputs.nixpkgs.lib.mkForce "localhost";
              system.stateVersion = "25.11";
              networking.hostName = "vm";
            }
          ];
      };
    };
}
