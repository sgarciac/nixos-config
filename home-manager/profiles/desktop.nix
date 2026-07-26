# User config for graphical machines. Pulled in by nixos/profiles/desktop.nix.
{ ... }:

{
  imports = [
    # Enables wayland.windowManager.hyprland and generates hyprland.lua
    ../modules/hyprland.nix
  ];

  programs.kitty.enable = true; # required for the default Hyprland config
}
