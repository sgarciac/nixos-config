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
  # Shell config for every host, headless included. Writes ~/.zshrc.
  #
  # The NixOS side keeps programs.zsh.enable (for /etc/zshenv and
  # environment.shells) but NOT ohMyZsh, so oh-my-zsh is sourced exactly once.
  # Note the option is spelled `oh-my-zsh` here; NixOS spells it `ohMyZsh`.
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "autojump"
      ];
      theme = "robbyrussell";
    };
  };

  # Writes $XDG_CONFIG_HOME/git/config (~/.config/git/config).
  #
  # Note the option names changed in home-manager 26.05: userName, userEmail,
  # aliases and extraConfig are now renamed into `settings`, which mirrors
  # git-config(1) section names directly. The old names still work but warn.
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "sergio garcia";
        email = "sergio.garcia@gmail.com";
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
