{
  description = "Configuración de NixOS para la VM del NAS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs = { self, nixpkgs, deploy-rs, sops-nix, ... }@inputs:
    let
      localSystem = "aarch64-linux";
      remoteSystem = "x86_64-linux";
    in {
      devShells.${localSystem}.default = nixpkgs.legacyPackages.${localSystem}.mkShell {
        packages = [
          nixpkgs.legacyPackages.${localSystem}.deploy-rs
          nixpkgs.legacyPackages.${localSystem}.sops
        ];
      };

      nixosConfigurations.nas-vm = nixpkgs.lib.nixosSystem {
        system = remoteSystem;
        modules = [
          ./hosts/nas-vm/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      deploy.nodes.nas-vm = {
        hostname = "192.168.64.3";
        user = "dani";
        fastConnection = true;
        remoteBuild = true;
        profiles.system = {
          path = deploy-rs.lib.${remoteSystem}.activate.nixos self.nixosConfigurations.nas-vm;
          user = "root";
        };
      };
    };
}
