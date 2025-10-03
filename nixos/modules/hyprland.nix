# ~/dotfiles/nix/modules/nixos/hyprland.nix
{ pkgs, ... }:

{
  # Enable Hyprland and Hyprlock system-wide
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # For running X11 apps
  };
  programs.hyprlock.enable = true;

  # Set environment variables for Wayland compatibility
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";      # For Electron apps
    MOZ_ENABLE_WAYLAND = "1";  # For Firefox
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
  };
}
