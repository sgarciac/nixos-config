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
{ pkgs, ... }:

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

      # No `theme` set. starship (below) exports PROMPT after oh-my-zsh runs, so
      # an oh-my-zsh theme has no visible effect — the old
      # `theme = "robbyrussell"` was never actually rendering. If you ever drop
      # starship, set a theme here again.
      plugins = [
        "git"
        # "autojump" is deliberately absent: oh-my-zsh's autojump plugin looks
        # for the shell hook in FHS paths that don't exist on NixOS, so it
        # silently did nothing. programs.autojump below wires it up properly.
      ];
    };
  };

  programs.starship.enable = true;
  programs.starship.settings = {
    scan_timeout = 200;
  };

  # CLI tools. These modules install the package *and* own its config, which is
  # why they replace the plain environment.systemPackages entries they came from.
  programs.bat.enable = true;
  programs.lsd.enable = true;
  programs.btop.enable = true;
  programs.ripgrep.enable = true;
  programs.autojump.enable = true;

  home.packages = with pkgs; [
    sbcl # no home-manager module, and nothing to configure
  ];

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
