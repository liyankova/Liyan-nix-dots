# ~/dotfiles/nix/modules/nixos/sddm.nix
{ pkgs, ... }:

{
  # Enable the SDDM display manager.
  services.displayManager.sddm = {
    enable = true;
    # Enable Wayland support in SDDM for a seamless experience.
    wayland.enable = true;
  };

  # Set the default session to Hyprland
  services.displayManager.defaultSession = "hyprland";

  # Enable libinput for touchpad gestures etc.
  services.libinput.enable = true;
}
