{ pkgs-unstable, ... }:

final: prev: {
  # This creates the attribute `unstable` in our main `pkgs` set
  unstable = import pkgs-unstable {
    system = prev.system;
    config.allowUnfree = true;
  };
}
