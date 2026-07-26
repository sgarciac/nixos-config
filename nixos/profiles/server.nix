# Headless machines: SSH in, no graphics stack.
#
# There is deliberately no NetworkManager here (it lives in profiles/desktop.nix).
# A wired server does not need it: networking.useDHCP and networking.dhcpcd.enable
# both default to true, so dhcpcd configures every interface that has no static
# address, with no configuration from us.
#
# Add networking config to a host only when that default is not what you want:
#   - WiFi on a headless box -> networking.networkmanager.enable, or
#     networking.wireless.enable with wpa_supplicant
#   - a fixed address -> networking.interfaces.<name>.ipv4.addresses
#     plus networking.defaultGateway and networking.nameservers
#   - networking.useNetworkd = true if you prefer systemd-networkd
{ ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      # Key-only login. IMPORTANT: add a key before switching, or you will lock
      # yourself out of a remote machine:
      #
      #   users.users.sergio.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # On by default; stated explicitly because it matters more here.
  networking.firewall.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
