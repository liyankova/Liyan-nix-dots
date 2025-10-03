# ~/dotfiles/nix/hosts/laptop-hp/configuration.nix
{ pkgs, inputs, meta, ... }:

{
  imports = [
    # Import machine-specific hardware settings
    ./hardware-configuration.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/sddm.nix
    ../../modules/nixos/hyprland.nix

  ];
  home-manager.nixpkgs.pkgs = pkgs;
  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  # Use the latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Networking
  networking.hostName = meta.hostname;
  networking.networkmanager.enable = true;

  # Timezone and Locale
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account
  users.users."${meta.username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "kvm" "games" ];
  };

  # System Services
  services.flatpak.enable = true;
  programs.adb.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Power Management
  powerManagement.cpuFreqGovernor = "schedutil";

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # System-wide Packages
  environment.systemPackages = with pkgs; [ btrfs-progs ];

  # System State Version
  system.stateVersion = meta.stateVersion;
}

# # ~/dotfiles/nix/hosts/laptop-hp/configuration.nix
# { pkgs, inputs, meta, ... }:
#
# {
#   imports = [
#     # Import machine-specific hardware settings
#     ./hardware-configuration.nix
#     # We will create and import more modules from ../../modules/nixos later
#   ];
#
#   # Set the hostname from our central config
#   networking.hostName = meta.hostname;
#
#   # Use the latest kernel
#   boot.kernelPackages = pkgs.linuxPackages_latest;
#
#   # Bootloader configuration
#   boot.loader = {
#     # --- GRUB Configuration ---
#     # Recommended for broader compatibility and dual-booting.
#     grub = {
#       enable = true;
#       device = "nodev"; # Let NixOS automatically find the EFI partition
#       efiSupport = true;
#       useOSProber = true; # Detect other OSes like Windows
#     };
#
#     # --- systemd-boot Configuration (for cloners) ---
#     # A simpler, faster bootloader for UEFI-only systems.
#     # systemd-boot = {
#     #   enable = true;
#     #   configurationLimit = 5;
#     # };
#   };
#
#   # Enable networking
#   networking.networkmanager.enable = true;
#
#   # Set your time zone
#   time.timeZone = "Asia/Jakarta";
#
#   # Configure locale
#   i18n.defaultLocale = "en_US.UTF-8";
#
#   # Basic user account
#   users.users."${meta.username}" = {
#     isNormalUser = true;
#     extraGroups = [ "wheel" "networkmanager" ]; # 'wheel' for sudo access
#   };
#
#   # Core Nix settings
#   nix.settings.experimental-features = [ "nix-command" "flakes" ];
#   nix.settings.auto-optimise-store = true;
#
#   # Allow unfree packages
#   nixpkgs.config.allowUnfree = true;
#
#   # Set the system's state version from our central config
#   system.stateVersion = meta.stateVersion;
# }
