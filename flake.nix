# ~/dotfiles/nix/flake.nix

{
  description = "Liyan's portable NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # --- Central Configuration ---
      meta = import ./meta.nix;

      # --- Main Package Set Definition ---
      # We define our system's primary package set here, once.
      # It's based on the stable `nixpkgs` input and includes our overlays.
      pkgs = import nixpkgs {
        system = meta.system;
        config.allowUnfree = true;
        overlays = [ (import ./overlays { pkgs-unstable = inputs.nixpkgs-unstable; }) ];
      };

      # --- Helper Libraries ---
      # This is kept for future use.
      lib = import ./lib { inherit inputs; };

    in {
      # --- NixOS System Configuration ---
      nixosConfigurations."${meta.hostname}" = nixpkgs.lib.nixosSystem {
        system = meta.system;
        specialArgs = { inherit inputs meta lib pkgs; };
        
        modules = [
          # THIS IS THE MOST CRITICAL LINE
          # It forces the entire NixOS build to use our defined `pkgs` above,
          # preventing interference from the host system's environment.
          { nixpkgs.pkgs = pkgs; }

          # Import the rest of our configuration
          ./hosts/${meta.hostname}/configuration.nix
          
          # Import the Home Manager module for NixOS
          inputs.home-manager.nixosModules.home-manager {
            # Pass arguments to Home Manager modules
            extraSpecialArgs = { inherit inputs meta lib pkgs; };
            users."${meta.username}" = ./home/${meta.username}/home.nix;
          }
        ];
      };

      # --- Standalone Home Manager Configuration ---
      homeConfigurations."${meta.username}" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs; # Use the same package set for consistency
        extraSpecialArgs = { inherit inputs meta lib; };
        modules = [ ./home/${meta.username}/home.nix ];
      };

      # --- Code Formatter ---
      formatter.${meta.system} = pkgs.alejandra;
    };
}
# {
#   description = "Liyan's portable NixOS and Home Manager configuration";
#
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
#     nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
#     home-manager.url = "github:nix-community/home-manager/release-25.05";
#     home-manager.inputs.nixpkgs.follows = "nixpkgs";
#     agenix.url = "github:ryantm/agenix";
#     agenix.inputs.nixpkgs.follows = "nixpkgs";
#   };
#
#   outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs:
#     let
#       meta = import ./meta.nix;
#       lib = import ./lib { inherit inputs; };
#
#       # This helper function creates the final package set for a given system
#       mkPkgs = system: import nixpkgs {
#         inherit system;
#         config.allowUnfree = true;
#         overlays = [ (import ./overlays { pkgs-unstable = inputs.nixpkgs-unstable; }) ];
#       };
#
#       # We create the package set for our system once
#       pkgs = mkPkgs meta.system;
#
#     in {
#       # NixOS configuration
#       nixosConfigurations."${meta.hostname}" = nixpkgs.lib.nixosSystem {
#         system = meta.system;
#         # Pass our final `pkgs` set and other args to all modules
#         specialArgs = { inherit inputs meta lib pkgs; };
#         modules = [
#           # This line FORCES all modules to use our `pkgs` set. This is the fix.
#           { nixpkgs.pkgs = pkgs; }
#
#           # Import the rest of our configuration
#           ./hosts/${meta.hostname}/configuration.nix
#           home-manager.nixosModules.home-manager
#           {
#             home-manager.users."${meta.username}" = ./home/${meta.username}/home.nix;
#           }
#         ];
#       };
#
#       # Standalone Home Manager configuration
#       homeConfigurations."${meta.username}" = home-manager.lib.homeManagerConfiguration {
#         # It also uses the same `pkgs` set for consistency
#         inherit pkgs;
#         extraSpecialArgs = { inherit inputs meta lib; };
#         modules = [ ./home/${meta.username}/home.nix ];
#       };
#
#       # Code Formatter
#       formatter.${meta.system} = pkgs.alejandra;
#     };
# }
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
