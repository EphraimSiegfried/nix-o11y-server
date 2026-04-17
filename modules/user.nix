{
  flake.modules.nixos.user =
    { config, ... }:
    {
      time.timeZone = config.primaryUser.timeZone;
      users.users = {
        ${config.primaryUser.username} = {
          isNormalUser = true;
          description = "${config.primaryUser.firstName} ${config.primaryUser.lastName}";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          openssh.authorizedKeys.keys = config.primaryUser.publicSSHKeys;
          initialPassword = "changeme";
        };
        "root" = {
          openssh.authorizedKeys.keys = config.primaryUser.publicSSHKeys;
        };
      };
    };
}
