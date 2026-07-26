# server — headless. No graphics stack, no Hyprland, no emacs.
#
# Gets base.nix (zsh, core CLI tools, tailscale, the sergio account, and the
# Home Manager *base* profile) plus server.nix. It deliberately does NOT import
# profiles/desktop.nix or anything from nixos/hardware/.
{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    # NOTE: still a placeholder — see the header of that file.
    ./hardware-configuration.nix

    ../../nixos/profiles/base.nix
    ../../nixos/profiles/server.nix

    # Uncomment if this machine is on WiFi rather than ethernet, then declare the
    # networks below. Read that file's header first — the pre-shared key must not
    # end up in the nix store.
    # ../../nixos/hardware/wifi.nix
  ];

  networking.hostName = "server";

  # WiFi networks, if hardware/wifi.nix is imported above:
  #
  # networking.wireless = {
  #   secretsFile = "/etc/wpa_supplicant.env";   # root:root, 600, not in git
  #   networks."my-ssid".pskRaw = "ext:psk_home";
  # };

  # Per-host Home Manager config (stateVersion, etc.)
  home-manager.users.sergio.imports = [ ../../home-manager/hosts/server.nix ];

  # REQUIRED BEFORE FIRST SWITCH, if this machine is remote.
  # profiles/server.nix turns off password and keyboard-interactive SSH login, so
  # without a key here you cannot get back in. Uncomment and add your public key:
  #
  # users.users.sergio.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAA... sergio@aorus"
  # ];

  # Set this to the NixOS release you first install this machine with, then
  # leave it alone. See the comment in hosts/aorus/default.nix.
  system.stateVersion = "26.05";
}
