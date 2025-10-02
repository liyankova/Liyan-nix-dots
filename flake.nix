# ~/dotfiles/nix/flake.nix
{
  description = "Liyan's portable NixOS and Home Manager configuration";

  inputs = {
    # Nixpkgs (Stable channel for the system base)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Unstable channel for bleeding-edge packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (version matching our stable channel)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets Management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs:
    let
      # Import central configuration and helper library
      meta = import ./meta.nix;
      lib = import ./lib { inherit inputs; };

      # Define overlays
      overlays = [ (import ./overlays) ];

      # Create a pkgs set with overlays applied
      pkgs = import nixpkgs {
        system = meta.system;
        config.allowUnfree = true;
        inherit overlays;
      };

    in
    {
      # Code Formatter
      formatter.${meta.system} = pkgs.alejandra;

      # NixOS configuration for the host specified in meta.nix
      nixosConfigurations."${meta.hostname}" = nixpkgs.lib.nixosSystem {
        system = meta.system;
        specialArgs = {
          inherit inputs meta lib;
          # Pass unstable pkgs explicitly for overlays
          pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${meta.system};
        };
        modules = [
          # Import the host-specific configuration
          ./hosts/${meta.hostname}/configuration.nix

          # Enable Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${meta.username}" = import ./home/${meta.username}/home.nix;
          }
        ];
      };

      # Standalone Home Manager configuration
      homeConfigurations."${meta.username}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs meta lib;
          pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${meta.system};
        };
        modules = [ ./home/${meta.username}/home.nix ];
      };
    };
}

# # ~/dotfiles/nix/flake.nix
# {
#   description = "Liyan's portable NixOS and Home Manager configuration";
#
#   inputs = {
#     # Nixpkgs
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
#     nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
#
#     # Home Manager
#     home-manager = {
#       url = "github:nix-community/home-manager/release-25.05";
#       # Ensure Home Manager uses the same Nixpkgs as the system
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#   };
#
#   outputs = { self, nixpkgs, home-manager, ... }@inputs:
#     let
#       # Import the central configuration file
#       meta = import ./meta.nix;
#     in
#     {
#       formatter.${meta.system} = nixpkgs.legacyPackages.${meta.system}.alejandra;
#       # NixOS configuration for the host specified in meta.nix
#       nixosConfigurations."${meta.hostname}" = nixpkgs.lib.nixosSystem {
#         system = meta.system;
#         specialArgs = { inherit inputs meta; }; # Pass inputs and meta to modules
#         modules = [
#           # Import the host-specific configuration
#           ./hosts/${meta.hostname}/configuration.nix
#
#           # Enable Home Manager for the user specified in meta.nix
#           home-manager.nixosModules.home-manager
#           {
#             home-manager.useGlobalPkgs = true;
#             home-manager.useUserPackages = true;
#             home-manager.extraSpecialArgs = { inherit inputs meta; };
#             home-manager.users."${meta.username}" = import ./home/${meta.username}/home.nix;
#           }
#         ];
#       };
#
#       # Standalone Home Manager configuration for non-NixOS systems
#       homeConfigurations."${meta.username}" = home-manager.lib.homeManagerConfiguration {
#         pkgs = nixpkgs.legacyPackages.${meta.system};
#         extraSpecialArgs = { inherit inputs meta; };
#         modules = [ ./home/${meta.username}/home.nix ];
#       };
#     };
# }
