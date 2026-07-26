# Shared by every machine, graphical or headless: boot, nix, locale, shell and
# the core CLI toolbox. Nothing in here should require a display.
{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../users/sergio.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages. Home Manager inherits this through useGlobalPkgs
  # below, which is why home profiles must not set nixpkgs.* themselves.
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # tailscale
  services.tailscale.enable = true;

  # 1password CLI. The GUI lives in profiles/desktop.nix.
  programs._1password.enable = true;

  # zsh
  #
  # This stays at the NixOS level even though the shell *configuration* now lives
  # in home-manager: it is what writes /etc/zshenv, /etc/zprofile and /etc/zshrc
  # and adds zsh to environment.shells, which a zsh login shell needs
  # (users.users.sergio.shell in ../users/sergio.nix).
  #
  # ohMyZsh is deliberately NOT enabled here — see
  # ../../home-manager/profiles/base.nix. This module would inject oh-my-zsh into
  # /etc/zshrc while home-manager injects it into ~/.zshrc, and both `source
  # $ZSH/oh-my-zsh.sh`, so enabling both loads oh-my-zsh twice per shell.
  programs.zsh.enable = true;

  # Kept at the system level on purpose: these are the tools you need as root.
  # Moving them to home.packages would leave `sudo` without an editor or git.
  # The user-facing CLI tools (bat, lsd, btop, ripgrep, autojump) moved to
  # ../../home-manager/profiles/base.nix, where they get configured as well as
  # installed. starship moved there too.
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor! The Nano editor is also installed by default.
    wget
    pciutils
    git
    tree
  ];

  # Home Manager runs as part of nixos-rebuild rather than standalone. Each
  # NixOS profile appends its matching home profile to this imports list, so
  # e.g. Hyprland config only reaches graphical hosts.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.sergio.imports = [ ../../home-manager/profiles/base.nix ];
  };
}
