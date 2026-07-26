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

  # Login manager
  services.displayManager.sddm.enable = true;

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

  # NOTE: waybar is deliberately NOT enabled here. It is managed entirely by
  # home-manager (programs.waybar in ../../home-manager/profiles/desktop.nix) so
  # that one place owns the package, the config and the systemd user service.
  # This NixOS module would add a second systemd unit for it.
  services.hypridle.enable = true;

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

  # Install firefox.
  programs.firefox.enable = true;

  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "sergio" ];
  };

  environment.systemPackages = with pkgs; [
    # Builds against X/GTK, so it stays out of the base profile. Use emacs-nox
    # if you ever want it on a headless host.
    emacs

    bibata-cursors
    nwg-look
  ];

  home-manager.users.sergio.imports = [ ../../home-manager/profiles/desktop.nix ];
}
