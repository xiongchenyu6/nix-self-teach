# START: simple_hydra.nix
{
  my-hydra = 
    { config, pkgs, ...}: {
      services.postfix = {
          enable = true;
          setSendmail = true;
      };
      services.postgresql = {
          enable = true;
          package = pkgs.postgresql;
          identMap =
            ''
              hydra-users hydra hydra
              hydra-users hydra-queue-runner hydra
              hydra-users hydra-www hydra
              hydra-users root postgres
              hydra-users postgres postgres
            '';
      };
  networking.firewall.allowedTCPPorts = [ config.services.hydra.port ];
  services.hydra = {
      enable = true;
      useSubstitutes = true;
      hydraURL = "https://hydra.example.org";
      notificationSender = "hydra@example.org";
      buildMachinesFiles = [];
      extraConfig = ''
        binary_cache_secret_key_file = /etc/nix/my-hydra/secret
      '';
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."hydra.example.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:3000";
    };
  };

  systemd.services.hydra-manual-setup = {
    description = "Create Admin User for Hydra";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    wantedBy = [ "multi-user.target" ];
    requires = [ "hydra-init.service" ];
    after = [ "hydra-init.service" ];
    environment = builtins.removeAttrs (config.systemd.services.hydra-init.environment) ["PATH"];
    script = ''
      if [ ! -e ~hydra/.setup-is-complete ]; then
        # create signing keys
        /run/current-system/sw/bin/install -d -m 551 /etc/nix/my-hydra
        /run/current-system/sw/bin/nix-store --generate-binary-cache-key my-hydra /etc/nix/my-hydra/secret /etc/nix/my-hydra/public
        /run/current-system/sw/bin/chown -R hydra:hydra /etc/nix/my-hydra
        /run/current-system/sw/bin/chmod 440 /etc/nix/my-hydra/secret
        /run/current-system/sw/bin/chmod 444 /etc/nix/my-hydra/public
        # create cache
        /run/current-system/sw/bin/install -d -m 755 /var/lib/hydra/cache
        /run/current-system/sw/bin/chown -R hydra-queue-runner:hydra /var/lib/hydra/cache
        # done
        touch ~hydra/.setup-is-complete
      fi
    '';
  };
  nix.gc = {
    automatic = true;
    dates = "15 3 * * *"; # [1]
  };

  nix.autoOptimiseStore = true;
  nix.trustedUsers = ["hydra" "hydra-evaluator" "hydra-queue-runner"];
  nix.buildMachines = [
    {
      hostName = "localhost";
      systems = [ "builtin" "x86_64-linux" "i686-linux" ];
      maxJobs = 6;
      # for building VirtualBox VMs as build artifacts, you might need other 
      # features depending on what you are doing
      supportedFeatures = [ "kvm" "nixos-test" "benchmark" ];
    }
  ];
};
}
# END: simple_hydra.nix
