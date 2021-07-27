{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    matthewcroughan.url = "github:matthewcroughan/nixcfg";
  };

  outputs = { self, nixpkgs, matthewcroughan, ... }@inputs: {
    nixosConfigurations = {
      pi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          "${matthewcroughan}/profiles/wireless.nix"
          "${matthewcroughan}/profiles/avahi.nix"
          "${matthewcroughan}/mixins/common.nix"
          {
           environment.systemPackages = with nixpkgs.legacyPackages.aarch64-linux.pkgs; [ vim git ];
           nix = {
             package = nixpkgs.legacyPackages.aarch64-linux.nixUnstable;
             extraOptions = ''
               experimental-features = nix-command flakes
             '';
            };
            zramSwap = {
              memoryPercent = 90;
              enable = true;
              algorithm = "zstd";
            };
            services.tailscale.enable = true;
            services.ttyd.enable = true;
            services.ttyd.openFirewall = true;
            services.openssh.enable = true;
            hardware.enableRedistributableFirmware = true;
            networking = {
              useDHCP = true;
              wireless = {
                enable = true;
                interfaces = [ "wlan0" ];
              };
              interfaces = {
                "wlan0".useDHCP = true;
                "eth0".useDHCP = true;
              };
              hostName = "pikvm";
            };
            users = {
              users.matthew = {
                password = "piratesrus";
                isNormalUser = true;
                openssh.authorizedKeys.keys = [
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiBSVCGJPjTnWUSjkZa6ow0hHZuJ5HOynU3Nx/b3VhdBikPa5ctcQ1nHQW662EIR3qgOxZtNl+ch2XClqIJ48WqwlfFONF/LjbDMITs5FQQBOVfxBQ62fkpjYz+26u6ZbScxGaVs/QnPxEsqey7GE+u5z5kksOmZy+2Q2LwjmkgRW1isLc9sTqegU+I50XQPaw35sUt8MO+htZeAi4MfrjZcj8xD40HMxP78D/LXPRl2TrEwRHaOA3iNfTwQklDUyNeNsCQtRGfLypMgTzAdxPAEcqaDWDxvizTtbK2EDP8kwTeITV2W4KziFZk4edM1MCzElWDzkM9GOeWa+Vf9T3 matthew@thinkpad"
                  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClm+SMN9Bg1HZ+MjH1VQYEXAnslGWT9564pj/KGO79WMQLUxdp3WWa1hQadf2PleAIEFEul3knrpRSEK3yHcCk3g+sCh3XIJcFZLesswe0V+kCAw+JBSd18ESJ4Qko+iDK95cDzucLFwXB10FMVKQCrX90KR+Fp6s6eJHcZGmpxTPgNulDpAjM2APluM3xBCe6zZzt+iNIzn3J8PRKbpNNbuw/LMRU8+udrGbLavUMcSk7ER9pAyLGhz//9aHWDPu7ZRje+vTWgnGFpzbtEzdjnP+2v45nLKWG7o7WdTAsAR8WSccjtNoBiVgSmpHr07zJ0/gTeL4PUkk3lbtzF/PdtTQGm3Ng4SjOBlhRVaTuKBlF2X/Rwq+W4LCbHVgA79MyhJxL2TDbKBPUSLfckqxP89e8Q7iQ4XjIHqVb50ojNNLGcOQRrHq14Twwx/ZDDQvMXCsLwM6vyoYa8KdSaASEr1clx78qNp9PHGlr+UztW+EsoZI7j1tzcHMmq2BSK90= matthew@t480
            "
                ];
                extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
              };
            };
          }
        ];
      };
    };
    images = {
      pi = self.nixosConfigurations.pi.config.system.build.sdImage;
    };
  };
}

