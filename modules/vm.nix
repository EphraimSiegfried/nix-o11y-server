{ inputs, ... }:
{
  perSystem = {
    packages.vm = inputs.self.nixosConfigurations.vm.config.system.build.vm;
  };

  flake.modules.nixos.vm = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    boot.loader.grub.devices = [ "/dev/sda" ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    virtualisation.vmVariant = {
      virtualisation.graphics = false;
      virtualisation.forwardPorts = [
        {
          from = "host";
          host.port = 8080;
          guest.port = 80;
        }
        {
          from = "host";
          host.port = 8443;
          guest.port = 443;
        }
      ];
    };
    services.getty.autologinUser = "root";
  };
}
