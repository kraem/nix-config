{ config, pkgs, ... }:

{

  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # iwd have a race condition with udev renaming wlanX to wlpXsX

  # https://bbs.archlinux.org/viewtopic.php?id=241803
  # We cannot override the ExecStart but we need to define it empty
  # once and then redefine it. This is accomplished with defining
  # ExecStart as a list in Nix.
  # Reference for drop-in files:
  # https://wiki.archlinux.org/index.php/systemd#Examples

  # https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/101
  # Apparently NetworkManager and IWD isn't only racing for interfaces-names
  # but also in which order they should be started. That's we've tried having
  # iwd starting after NetworkManager.
  # Have tested having iwd starting before NetworkManager, doesn't work.
  # It all works after suspending if; systemctl restart both iwd and NetworkManager

  #systemd.services.iwd = {
  #  path = [ pkgs.iwd ];
  #  unitConfig = {
  #    After = [
  #      "systemd-udevd.service"
  #    ];
  #    Before = [
  #      "NetworkManager.service"
  #    ];
  #  };
  #  serviceConfig = {
  #    ExecStart = [
  #      ""
  #      "${pkgs.iwd}/libexec/iwd --nointerfaces \"wlan[0-9]\""
  #    ];
  #  };
  #};

  # Same thing but trying to restart it after suspend

  #systemd.services.iwd = {
  #  path = [ pkgs.iwd ];
  #  wantedBy = ["sleep.target"];
  #  unitConfig = {
  #    # WantedBy and After from here: https://github.com/systemd/systemd/issues/6364#issuecomment-316647050
  #    #"systemd-suspend.service"
  #    #"systemd-hybrid-sleep.service"
  #    #"systemd-hibernate.service"
  #    After= [
  #      "sleep.target"

  #      "systemd-udevd.service"
  #      "NetworkManager.service"
  #    ];
  #  };
  #  serviceConfig = {
  #    ExecStart = [
  #      ""
  #      "${pkgs.iwd}/libexec/iwd --nointerfaces \"wlan[0-9]\""
  #    ];
  #  };
  #};

  # Trying to have NetworkManager to explicitely restart after suspend too

  #systemd.services.NetworkManager = {
  #  wantedBy = ["sleep.target"];
  #  unitConfig = {
  #    After= [
  #      "sleep.target"
  #    ];
  #  };
  #};

  #environment.etc.iwdconf = {
  #  text = ''
  #    [General]
  #    UseDefaultInterface=true
  #  '';

  #  # These have been tested to but don't know how to let iwd solve all of the dhcp
  #  # management instead of NetworkManager as NM doesn't have a "none" option
  #    #[General]
  #    #EnableNetworkConfiguration=true
  #    #[Network]
  #    #NameResolvingService=systemd

  #  mode = "0444";
  #  target = "iwd/main.conf";
  #};

  # iwd: These are failed attempts to solve this

  # https://wiki.archlinux.org/index.php/Iwd#Systemd_unit_fails_on_startup_due_to_device_not_being_available
  # Doesn't work
  #systemd.services.iwd.unitConfig = {
  #After="systemd-udevd.service";
  #};

  # https://insanity.industries/post/racefree-iwd/
  # Doesn't work
  #systemd.services.iwd.unitConfig = {
  #Requires = "sys-subsystem-net-devices-wlp3s0.device";
  #After = "sys-subsystem-net-devices-wlp3s0.device";
  #};

  # https://wiki.archlinux.org/index.php/Iwd#Systemd_unit_fails_on_startup_due_to_device_not_being_available
  # Doesn't work
  #environment.etc.iwdconf = {
  #  text = ''
  #    [General]
  #    use_default_interface=true
  #  '';
  #  mode = "0444";
  #  target = "iwd/main.conf";
  #};

  # https://wiki.archlinux.org/index.php/Network_configuration#Change_interface_name
  #services.udev.extraRules = ''
  #  SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ac:bc:32:95:85:91", NAME=="wlp3s0"
  #'';


  # Simple setup with systemd-networkd + iwd
  # No network management so far, only simple wifi

  #networking.wireless.iwd.enable = true;
  #systemd.network = {
  #  enable = true;
  #};

  # These are iwd settings are from *someone* in #nixos on freenode
  # Not specific to solve the race condition but to fix something with
  # DNS that I can't remember

  #environment.etc.iwdconf = {
  #  text = ''
  #    [General]
  #    enable_network_config=false
  #    dns_resolve_method=resolvconf

  #    [Rank]
  #    rank_5g_factor=4.0'';
  #  mode = "0444";
  #  target = "iwd/main.conf";
  #};

  ## Enable iwd to access resolvconf
  #systemd.services.iwd = {
  #  path = [ pkgs.openresolv ];
  #  serviceConfig = { ReadWritePaths = [ "/run/resolvconf" "/etc/resolv.conf" ]; };
  #};
}
