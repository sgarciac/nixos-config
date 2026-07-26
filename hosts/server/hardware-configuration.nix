# ============================================================================
# PLACEHOLDER — THIS IS NOT A REAL HARDWARE CONFIG.
#
# Replace this entire file with the output of, run ON the server itself:
#
#     nixos-generate-config --show-hardware-config
#
# It encodes that machine's filesystems, initrd kernel modules and CPU
# microcode — none of which can be guessed from here.
#
# One thing to check once you have the real file: base.nix assumes a UEFI
# machine (systemd-boot + canTouchEfiVariables). If this box is BIOS/legacy boot
# or a VM without EFI, override the bootloader in hosts/server/default.nix:
#
#     boot.loader.systemd-boot.enable = lib.mkForce false;
#     boot.loader.grub = { enable = true; device = "/dev/sda"; };
#
# Networking needs nothing here — see the header of nixos/profiles/server.nix.
#
# Until replaced, `nixos-rebuild build --flake .#server` and `nix flake check`
# fail with:
#
#     The 'fileSystems' option does not specify your root file system.
#
# That failure is deliberate — a placeholder that evaluated successfully could
# silently build an unbootable system.
# ============================================================================
{ lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
