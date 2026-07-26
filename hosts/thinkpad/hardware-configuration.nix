# ============================================================================
# PLACEHOLDER — THIS IS NOT A REAL HARDWARE CONFIG.
#
# Replace this entire file with the output of, run ON the thinkpad itself:
#
#     nixos-generate-config --show-hardware-config
#
# It has to be generated there because it encodes that machine's filesystems,
# LUKS UUIDs, initrd kernel modules and CPU microcode — none of which can be
# guessed from here.
#
# Until you do, `nixos-rebuild build --flake .#thinkpad` and `nix flake check`
# fail with:
#
#     The 'fileSystems' option does not specify your root file system.
#
# That failure is deliberate. A placeholder that evaluated successfully could
# silently build an unbootable system, so this one refuses to build at all.
# If the failing `nix flake check` is in your way, comment out the `thinkpad`
# line in flake.nix until the laptop is installed.
# ============================================================================
{ lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
