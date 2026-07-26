# User config shared by every machine.
#
# This is applied through the Home Manager NixOS module (wired up in
# nixos/profiles/base.nix), not standalone. Two consequences:
#
#   - home.username / home.homeDirectory are set automatically from
#     users.users.sergio, so don't set them here.
#   - nixpkgs.* must NOT be set here. useGlobalPkgs = true means those options
#     are never even imported, so setting one is an unknown-option error.
#     Configure nixpkgs at the NixOS level instead.
{ ... }:

{
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
