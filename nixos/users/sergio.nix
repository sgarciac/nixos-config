# The user account itself. Shared by every machine.
#
# GUI packages for this user are added by nixos/profiles/desktop.nix; the two
# `packages` lists merge.
{ pkgs, ... }:

{
  # Don't forget to set a password with 'passwd'.
  users.users."sergio" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "sergio garcia";

    # "networkmanager" is only a real group on hosts importing the desktop
    # profile. On a headless host it is silently ignored: NixOS builds group
    # membership from the group side, and only the *primary* group must exist.
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
