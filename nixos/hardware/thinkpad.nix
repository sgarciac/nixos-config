# ThinkPad laptop bits.
#
# Deliberately thin: the GPU (Intel vs AMD) and CPU microcode are unknown until
# hosts/thinkpad/hardware-configuration.nix is generated on the actual machine.
# Once it is, consider adding:
#   - services.xserver.videoDrivers (usually unnecessary — the modesetting
#     driver handles both Intel and AMD integrated graphics)
#   - power management: services.tlp.enable, or leave NetworkManager's
#     power-profiles-daemon in place (the two conflict, so pick one)
#   - services.fwupd.enable for firmware updates
{ ... }:

{
  hardware.enableRedistributableFirmware = true;

  # Enable touchpad support (enabled by default in most desktopManagers).
  services.libinput.enable = true;
}
