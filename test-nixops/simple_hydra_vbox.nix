# START simple_hydra_vbox.nix
{
  my-hydra =
    { config, pkgs, ... }: {
     deployment.targetEnv = "virtualbox";
     deployment.virtualbox.memorySize = 4096;
     deployment.virtualbox.vcpu = 2;
     deployment.virtualbox.headless = true;
     services.nixosManual.showManual         = false;
     services.ntp.enable                     = false;
     services.openssh.allowSFTP              = false;
     services.openssh.passwordAuthentication = false;
     users = {
        mutableUsers = false;
        users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
      };
    };
}
# END: simple_hydra_vbox.nix
