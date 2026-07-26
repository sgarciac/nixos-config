# Per-host user config for aorus. Imported from hosts/aorus/default.nix.
#
# Only holds things that genuinely differ per machine — monitors, mostly.
# Everything else lives in ../profiles/.
{ ... }:

{
  # Unchanged from what the shared module used to set: let Hyprland pick the
  # EDID-preferred mode and auto-place/auto-scale. This is the catch-all rule
  # (empty output = every monitor).
  wayland.windowManager.hyprland.settings.monitor = {
    output = "";
    mode = "preferred";
    position = "auto";
    scale = "auto";
  };
}
