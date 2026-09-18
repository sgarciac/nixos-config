# Development profile: adds development tools for any host.
#
# Import alongside base.nix in hosts/<name>/default.nix:
#
#   imports = [
#     ../../nixos/profiles/base.nix
#     ../../nixos/profiles/development.nix
#   ];
{ ... }:

{
  # User-level development tools (Rust, etc.)
  home-manager.users.sergio.imports = [
    ../../home-manager/profiles/development.nix
  ];
}
