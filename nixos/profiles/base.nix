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
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "autojump"
      ];
      theme = "robbyrussell";
    };
  };
  programs.starship.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor! The Nano editor is also installed by default.
    ripgrep
    wget
    pciutils
    git
    bat
    stow
    lsd
    autojump
    sbcl
    btop
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
