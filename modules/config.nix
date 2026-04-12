# This file defines variables I use all over my config
# I never define these variables indirectly by setting default values

{ lib, ... }:
let
  userOpts =
    { ... }:
    {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          default = "siegi";
        };
        firstName = lib.mkOption {
          type = lib.types.str;
          default = "Ephraim";
        };
        lastName = lib.mkOption {
          type = lib.types.str;
          default = "Siegfried";
        };
        email = lib.mkOption {
          type = lib.types.str;
          default = "ephraim.siegfried@proton.me";
        };
        publicSSHKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdANrCkeXTrZha/w3pvg/vCZWmuRsy7cI6PmgVfWH8c siegi@blinkybill"
          ];
        };
        timeZone = lib.mkOption {
          type = lib.types.str;
          default = "Europe/Zurich";
        };
      };
    };
  serviceOpts =
    { ... }:
    {
      options = {
        subdomain = lib.mkOption {
          type = lib.types.str;
        };
        port = lib.mkOption {
          type = lib.types.int;
        };
        proxyWebsockets = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    };
in
{
  options = {
    primaryUser = lib.mkOption {
      type = lib.types.submodule userOpts;
      default = { };
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "qew.ch";
    };
    myServices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule serviceOpts);
      default = { };
      description = "Services to expose via nginx";
    };
  };
}
