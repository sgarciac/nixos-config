# Development tools profile.
#
# Import from hosts/<name>/default.nix after the base profile.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
  ];
}
