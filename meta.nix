# ~/dotfiles/nix/meta.nix
{
  # -- User Configuration --
  # Change this to your username.
  # This is used to set the home directory and user-specific settings.
  username = "liyan";

  # -- System Configuration --
  # Change this to your machine's hostname.
  # This is used to select the correct host configuration from the `./hosts` directory.
  hostname = "laptop-hp";
  
  # Your system's architecture.
  system = "x86_64-linux";

  # NixOS release version.
  # Check available versions here: https://nixos.wiki/wiki/NixOS_versions
  stateVersion = "25.05";
}
