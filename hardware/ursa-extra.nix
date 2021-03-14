{ config, pkgs, lib, ... }:

{

  # hopefully this solves random freezes
  # if not try:
  # 1. Power Supply Idle Control in BIOS
  # 2. kernel param `processor.max_cstate=1`
  hardware.cpu.amd.updateMicrocode = true;

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

  # TODO
  # not yet working correctly with hashcat
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  imports = [
    ./bluetooth
  ];

}
