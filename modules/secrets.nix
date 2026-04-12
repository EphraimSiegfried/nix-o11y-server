{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { config, ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        defaultSopsFile = "${inputs.self}/secrets.yaml";
      };
    };
}
