# ~/dotfiles/nix/flake.nix
{
  description = "Liyan's portable NixOS and Home Manager configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      # Ensure Home Manager uses the same Nixpkgs as the system
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Import the central configuration file
      meta = import ./meta.nix;
    in
    {
      # NixOS configuration for the host specified in meta.nix
      nixosConfigurations."${meta.hostname}" = nixpkgs.lib.nixosSystem {
        system = meta.system;
        specialArgs = { inherit inputs meta; }; # Pass inputs and meta to modules
        modules = [
          # Import the host-specific configuration
          ./hosts/${meta.hostname}/configuration.nix

          # Enable Home Manager for the user specified in meta.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs meta; };
            home-manager.users."${meta.username}" = import ./home/${meta.username}/home.nix;
          }
        ];
      };

      # Standalone Home Manager configuration for non-NixOS systems
      homeConfigurations."${meta.username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${meta.system};
        extraSpecialArgs = { inherit inputs meta; };
        modules = [ ./home/${meta.username}/home.nix ];
      };
    };
}
