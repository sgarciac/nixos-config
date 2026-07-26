# thinkpad — laptop, no discrete GPU.
{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    # NOTE: still a placeholder — see the header of that file.
    ./hardware-configuration.nix

    ../../nixos/profiles/base.nix
    ../../nixos/profiles/desktop.nix
    ../../nixos/hardware/thinkpad.nix
  ];

  networking.hostName = "thinkpad";

  # Set this to the NixOS release you first install the laptop with, then leave
  # it alone. See the comment in hosts/aorus/default.nix.
  system.stateVersion = "26.05";
}
