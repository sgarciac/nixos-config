# Graphical machines: Wayland/Hyprland session, audio, fonts and GUI apps.
# Hardware-specific graphics drivers live in ../hardware/ instead.
{ pkgs, ... }:

{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.graphics.enable = true;

  # Login manager - SDDM with Catppuccin Mocha theme
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha";
  };

  # Catppuccin SDDM theme
  environment.systemPackages = with pkgs; [
    catppuccin-sddm
  ];

  # Enable the COSMIC login manager / desktop environment
  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.desktopManager.plasma6.enable = true;

  # hyprland
  # this needs to be defined here and not in home manager
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprland.xwayland.enable = true;

  # NOTE: waybar and hypridle are deliberately NOT enabled here. Both are managed
  # entirely by home-manager (../../home-manager/profiles/desktop.nix) so that one
  # place owns the package, the config and the systemd user service. Each of these
  # NixOS modules binds its own unit to graphical-session.target, so enabling them
  # here as well gives you two of each — and neither can write the per-user config
  # file that hypridle needs in order to do anything.

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # firefox moved to home-manager so the 1Password extension can be declared.
  # emacs moved to programs.emacs there. bibata-cursors is now pulled in by
  # home.pointerCursor, and nwg-look is gone entirely — it was a GUI for editing
  # GTK settings by hand, which the `gtk` module now does declaratively.

  # Binary cache for the llm-agents.nix packages installed in the home desktop
  # profile. Without this every agent is built from source against their pinned
  # nixpkgs-unstable, which is slow and pointless — they push daily CI builds.
  #
  # `extra-*` rather than plain `substituters`/`trusted-public-keys`, which would
  # replace cache.nixos.org instead of appending to it.
  nix.settings = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "sergio" ];
  };

  home-manager.users.sergio.imports = [ ../../home-manager/profiles/desktop.nix ];
}
