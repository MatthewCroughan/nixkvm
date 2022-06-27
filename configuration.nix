{ pkgs, config, lib, ... }: {

  imports = [ ./pi-gpu.nix ];

  nixpkgs.overlays = [
    (final: prev: {
        python39Packages = final.python39.pkgs;
        python39 = prev.python39.override {
          packageOverrides = self: super: {
            vpype = super.buildPythonPackage rec {
              pname = "vpype";
              version = "1.10.0";
              src = super.fetchPypi {
                inherit pname version;
                sha256 = "";
              };
              doCheck = false;
#              buildInputs = [ self.websocket-client self.pyserial ];
            };
            vsketch = super.buildPythonPackage rec {
              pname = "vpype";
              version = "1e9ebc540a3ef873d39e04e728a8e96a3faedb80";
              src = prev.fetchFromGitHub {
                owner = "abey79";
                repo = pname;
                rev = version;
                sha256 = "0rs9bxxrw4wscf4a8yl776a8g880m5gcm75q06yx2cn3lw2b7v22";
              };
              doCheck = false;
            };
          };
        };
      raspberrypifw = prev.raspberrypifw.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "raspberrypi";
          repo = "firmware";
          rev = "56e76a43e4df5872f509c2ace299e692de3ea9a6";
          hash = "";
        };
      });
    })
  ];

#  boot.loader = {
#    generic-extlinux-compatible.enable = lib.mkForce false;
#    raspberryPi = {
#      enable = true;
#      version = 4;
#      uboot.enable = false;
#    };
#  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = lib.mkForce [ "bridge" "macvlan" "tap" "tun" "loop" "atkbd" "ctr" ];
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" "vfat" ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    inkscape
    candle
    (builtins.getFlake "github:nixos/nixpkgs/891016b5cf1998ea84852adac52c65c5ccd3e802").legacyPackages.${pkgs.hostPlatform.system}.haskellPackages.juicy-gcode
    python39Packages.vsketch
    python39Packages.vpype
  ];

  nix = lib.mkForce {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.openssh.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
  };

  networking = {
    networkmanager.unmanaged = [ "wlan0" ];
    useDHCP = true;
    wireless = {
      enable = true;
      interfaces = ["wlan0"];
    };
    interfaces = {
      "wlan0".useDHCP = true;
      "eth0".useDHCP = true;
    };
    hostName = "penplotter";
  };

  users = {
    users.matthew = {
      password = "piratesrus";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClm+SMN9Bg1HZ+MjH1VQYEXAnslGWT9564pj/KGO79WMQLUxdp3WWa1hQadf2PleAIEFEul3knrpRSEK3yHcCk3g+sCh3XIJcFZLesswe0V+kCAw+JBSd18ESJ4Qko+iDK95cDzucLFwXB10FMVKQCrX90KR+Fp6s6eJHcZGmpxTPgNulDpAjM2APluM3xBCe6zZzt+iNIzn3J8PRKbpNNbuw/LMRU8+udrGbLavUMcSk7ER9pAyLGhz//9aHWDPu7ZRje+vTWgnGFpzbtEzdjnP+2v45nLKWG7o7WdTAsAR8WSccjtNoBiVgSmpHr07zJ0/gTeL4PUkk3lbtzF/PdtTQGm3Ng4SjOBlhRVaTuKBlF2X/Rwq+W4LCbHVgA79MyhJxL2TDbKBPUSLfckqxP89e8Q7iQ4XjIHqVb50ojNNLGcOQRrHq14Twwx/ZDDQvMXCsLwM6vyoYa8KdSaASEr1clx78qNp9PHGlr+UztW+EsoZI7j1tzcHMmq2BSK90= matthew@t480"
      ];
      extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    };
  };
}
