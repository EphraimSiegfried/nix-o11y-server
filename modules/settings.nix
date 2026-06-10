# This file defines variables I use all over my config
# I never define these variables indirectly by setting default values

{ lib, ... }:
let
  userOpts =
    { ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "siegi";
        };
        email = lib.mkOption {
          type = lib.types.str;
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
  flake.modules.nixos.settings = {
    options = {
      admin = lib.mkOption {
        type = lib.types.submodule userOpts;
        default = { };
      };
      domain = lib.mkOption {
        type = lib.types.str;
      };
      webServices = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule serviceOpts);
        default = { };
      };
    };

    config = {
      admin = {
        name = "siegi";
        email = "ephraim.siegfried@proton.me";
        publicSSHKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdANrCkeXTrZha/w3pvg/vCZWmuRsy7cI6PmgVfWH8c siegi@blinkybill"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1R2gEuXslK413gWBE4tOA894zO/MkhZrAK/LyRcsmo siegi@thymian"
        ];
        timeZone = "Europe/Zurich";
      };
      domain = "qew.ch";
    };
  };
}
