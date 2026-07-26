# Per-host user config for the thinkpad. Imported from hosts/thinkpad/default.nix.
{ ... }:

{
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";

  # 1920x1080 at scale 1.
  #
  # Two things were plausibly making this look "too low", and this addresses
  # both: `mode = "preferred"` picks whatever the panel reports via EDID, and
  # `scale = "auto"` lets Hyprland choose a fractional scale — on a ~14" 1080p
  # panel that often lands on 1.25 or 1.5, which makes everything oversized and
  # reads as a low resolution even though the mode is correct.
  #
  # NOTE: `output = ""` is the catch-all, so this also applies to an external
  # monitor if you plug one in — which is wrong for anything above 1080p. Once
  # you send me `hyprctl monitors` I'll pin this to the internal panel by name
  # (usually eDP-1) and leave externals on preferred/auto.
  #
  # If the panel turns out not to support 1920x1080, Hyprland logs
  # "Monitor <name>: no mode found" and falls back, so nothing breaks — it just
  # won't change. `hyprctl monitors` lists the modes it will accept.
  wayland.windowManager.hyprland.settings.monitor = {
    output = "";
    mode = "1920x1080";
    position = "auto";
    scale = 1;
  };
}
