{ config, pkgs, lib, ... }:
{
  boot.kernelPatches = [
    {
      name = "v3d-enable-part1";
      patch = pkgs.fetchpatch {
        url = "https://patchwork.kernel.org/series/646576/mbox/";
        excludes = ["Documentation/*"];
        sha256 = "sha256-rn2+D2NjUTbfUtLb7uDBTzIpYIRo90p9SqxB1a2/XuY=";
      };
    }
    {
      name = "v3d-enable-part2";
      patch = pkgs.fetchpatch {
        url = "https://patchwork.kernel.org/series/647129/mbox/";
        excludes = ["Documentation/*"];
        sha256 = "sha256-+ohSoSvdTEqVCgWDIYy3Mq8aulDNYtnHaQ1K85y3e4k=";
      };
    }
    {
      name = "vc4-enable-cec";
      patch = null;
      extraConfig = ''
        DRM_VC4_HDMI_CEC y
      '';
    }
  ];

  hardware = {
    opengl.enable = true;
    deviceTree = {
      overlays = [
        {
          name = "rpi4-cma-overlay";
          dtsText = ''
            // SPDX-License-Identifier: GPL-2.0
            /dts-v1/;
            /plugin/;
            / {
              compatible = "brcm,bcm2711";
              fragment@0 {
                target = <&cma>;
                __overlay__ {
                  size = <(512 * 1024 * 1024)>;
                };
              };
            };
          '';
        }
      ];
    };
  };
}
