{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets."users/cris/password" = {};

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.mutableUsers = false;
  users.users.dani = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$MwMQPs6Ua99s/Mpq$Imm8SbjeIGJZRkib6If.jdSfdLfqzuGKa/wykGoXOzvk7bekQpMVNaqadO63KIbjx9UFRRgKfFvg.hvyJrw39/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq21O6t1Q2QHfp9ypCIeDUqJ0PjauigrMXKKvvVL4I/ dani@mac"
    ];
  };

  users.users.cris = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."users/cris/hashedPassword".path;
  };

  security.sudo.extraRules = [
    {
      users = [ "dani" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    git
    cowsay
    ponysay
  ];

  system.stateVersion = "25.05";

}