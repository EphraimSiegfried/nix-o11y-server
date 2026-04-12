{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.nixosConfigurations =
    let
      main_modules = with inputs.self.modules.nixos; [
        inputs.srvos.nixosModules.server
        user
        gatus
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
            secrets
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
              system.stateVersion = "25.11";
              networking.hostName = "vm";
            }
          ];
      };
    };
}
