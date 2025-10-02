# ~/dotfiles/nix/home/liyan/home.nix
{ pkgs, inputs, meta, ... }:

{
  # This sets the home-manager state version
  home.stateVersion = meta.stateVersion;

  # Basic user information
  home.username = meta.username;
  home.homeDirectory = "/home/${meta.username}";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # More configurations will be imported from ./features/
}
