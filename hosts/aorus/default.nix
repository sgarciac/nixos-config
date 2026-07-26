# aorus — AMD desktop with an NVIDIA GPU.
{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../nixos/profiles/base.nix
    ../../nixos/profiles/desktop.nix
    ../../nixos/hardware/nvidia.nix
  ];

  networking.hostName = "aorus";

  # This value determines the NixOS release from which the default settings for
  # stateful data, like file locations and database versions on your system were
  # taken. It's perfectly fine and recommended to leave this value at the release
  # version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
