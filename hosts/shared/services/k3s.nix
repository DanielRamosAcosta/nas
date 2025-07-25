{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [];
  };
}

