{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    matthewcroughan.url = "github:matthewcroughan/nixcfg";
  };

  outputs = { self, nixpkgs, matthewcroughan, nixos-hardware, ... }@inputs: {
    nixosConfigurations = {
      pi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          "${matthewcroughan}/profiles/wireless.nix"
          "${matthewcroughan}/profiles/avahi.nix"
          "${matthewcroughan}/mixins/common.nix"
          ./configuration.nix
        ];
      };
    };
    images = {
      pi = self.nixosConfigurations.pi.config.system.build.sdImage;
    };
  };
}

