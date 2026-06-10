{
  flake.modules.nixos.user =
    { config, ... }:
    {
      time.timeZone = config.admin.timeZone;
      users.users = {
        ${config.admin.name} = {
          isNormalUser = true;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          openssh.authorizedKeys.keys = config.admin.publicSSHKeys;
          initialPassword = "changeme";
        };
        "root" = {
          openssh.authorizedKeys.keys = config.admin.publicSSHKeys;
        };
      };
    };
}
