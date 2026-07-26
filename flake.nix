{
  description = "Sergio's nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      # Each hosts/<name>/ directory is a self-contained NixOS module: it imports
      # its own hardware-configuration.nix plus whichever profiles it needs from
      # nixos/profiles/ and nixos/hardware/. Home Manager comes along via
      # nixos/profiles/base.nix, so there is no separate homeConfigurations
      # output and no separate `home-manager switch` step.
      mkHost =
        hostPath:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ hostPath ];
        };
    in
    {
      # Rebuild with: sudo nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = {
        aorus = mkHost ./hosts/aorus;
        thinkpad = mkHost ./hosts/thinkpad;
        server = mkHost ./hosts/server;
      };
    };
}
