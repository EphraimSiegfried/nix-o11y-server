{
  flake.modules.nixos.networking = {
    services.timesyncd.enable = false;
    services.chrony = {
      enable = true;
      servers = [
        "time.cloudflare.com"
        "nts.ntp.se"
        "ptbtime1.ptb.de"
      ];
      enableNTS = true;
    };
  };
}
