{ config, pkgs, lib, ... }:

{

  # Kingston A2000 goes into powersaving mode
  # which results in the nvme ssd not responding.
  # This disables it
  #
  # More info:
  # https://bugzilla.kernel.org/show_bug.cgi?id=195039
  # https://tekbyte.net/2020/fixing-nvme-ssd-problems-on-linux/
  #
  # Arch wiki has some commands listed to verify if it's active or not
  # https://wiki.archlinux.org/index.php/Solid_state_drive/NVMe#Power_Saving_APST
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
  ];

  # tcp_ecn = 0 according to
  # https://bbs.archlinux.org/viewtopic.php?id=240916
  # https://github.com/Baughn/machine-config/blob/3eed598f8b3b7fb6c7ab93615c2864f8e4652af4/modules/basics.nix#L109
  # haven't tested:
  # https://bugzilla.kernel.org/show_bug.cgi?id=198645
  boot.kernel.sysctl = {
    "net.ipv4.tcp_ecn" = 0;
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  powerManagement.enable = false;

  imports = [
    ./bluetooth
  ];

}
