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

  # Per-host user config (monitors). Merges with the imports added by
  # profiles/base.nix and profiles/desktop.nix.
  home-manager.users.sergio.imports = [ ../../home-manager/hosts/thinkpad.nix ];

  # Set this to the NixOS release you first install the laptop with, then leave
  # it alone. See the comment in hosts/aorus/default.nix.
  system.stateVersion = "26.05";
}
