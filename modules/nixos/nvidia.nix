# ~/dotfiles/nix/modules/nixos/nvidia.nix
{ config, pkgs, lib, ... }:

{
  # This module configures NVIDIA drivers for a hybrid graphics laptop (Intel + NVIDIA).
  # It is specifically tailored for older GPUs requiring legacy drivers.

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
    nvidiaSettings = true;

    # The GeForce MX130 requires a legacy driver.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

    # PRIME Render Offload Configuration
    prime = {
      sync.enable = true;
      # Bus IDs are derived from `lspci` output.
      # Intel: 00:02.0 -> PCI:0:2:0
      # NVIDIA: 02:00.0 -> PCI:2:0:0
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };
}
