# WiFi for headless hosts. Opt in per host — import this from a host whose link
# is wireless; wired servers need nothing (see nixos/profiles/server.nix).
#
# DO NOT combine this with profiles/desktop.nix. Desktops get WiFi through
# NetworkManager, and networkmanager.nix asserts that networking.wireless.networks
# and NetworkManager are mutually exclusive unless you mark interfaces as
# `unmanaged`. Importing both fails eval with that message.
#
# ---------------------------------------------------------------------------
# Declaring networks (do this in the HOST file, not here)
#
# Never use `psk` — it lands in the world-readable nix store in plaintext.
# `pskRaw` only accepts 64 hex chars or an `ext:` reference, so use `ext:`:
#
#   networking.wireless = {
#     secretsFile = "/etc/wpa_supplicant.env";
#     networks."my-ssid".pskRaw = "ext:psk_home";
#     networks."other-ssid".pskRaw = "ext:psk_other";
#   };
#
# Then, on the machine itself and NOT in this repo:
#
#   # /etc/wpa_supplicant.env — root:root, chmod 600
#   psk_home=correcthorsebatterystaple
#   psk_other=anotherpassphrase
#
# Chicken-and-egg warning: if WiFi is the machine's only link, that secrets file
# has to exist before the first boot that needs the network, because you cannot
# SSH in to create it. Write it during installation.
# ---------------------------------------------------------------------------
{ ... }:

{
  # WiFi chipsets need vendor firmware blobs.
  hardware.enableRedistributableFirmware = true;

  networking.wireless = {
    enable = true;

    # Allow adding networks at runtime with `wpa_cli` alongside the declarative
    # ones, so a new SSID doesn't strictly require a rebuild.
    allowAuxiliaryImperativeNetworks = true;
  };
}
