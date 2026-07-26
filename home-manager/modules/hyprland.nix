{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
  };

  xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;
}
