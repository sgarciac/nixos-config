# User config for graphical machines. Pulled in by nixos/profiles/desktop.nix.
{ pkgs, ... }:

let
  # Comes straight from the nix store, so there is no local file to keep in sync
  # and both machines get the same image. `gnomeFilePath` is a passthru on the
  # wallpaper derivation that gives the full path to the png, which saves us
  # hardcoding the filename under $out/share/backgrounds/nixos/.
  wallpaper = pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath;
in
{
  imports = [
    # Enables wayland.windowManager.hyprland and generates hyprland.lua
    ../modules/hyprland.nix
  ];

  programs.kitty.enable = true; # required for the default Hyprland config

  # Binaries that modules/hyprland.nix references by name. Without these the
  # matching keybind or autostart entry fails silently — Hyprland just execs the
  # command and nothing happens.
  #
  # waybar and hyprpaper are absent on purpose: the modules below install them.
  home.packages = with pkgs; [
    hyprlauncher # SUPER + R (menu)
    kdePackages.dolphin # SUPER + E (fileManager)
    networkmanagerapplet # provides nm-applet, autostarted into waybar's tray

    brightnessctl # XF86MonBrightness{Up,Down}
    playerctl # XF86Audio{Next,Prev,Play,Pause}

    # GUI apps (moved here from users.users.sergio.packages)
    kdePackages.kate
    #  thunderbird
  ];

  # Wallpaper daemon. Owns hypr/hyprpaper.conf and a systemd user service, which
  # is why hyprpaper is no longer launched from the hyprland.start hook.
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [ wallpaper ];
      # "<monitor>,<path>"; an empty monitor field means every output.
      wallpaper = [ ",${wallpaper}" ];
    };
  };

  # Managed here rather than via programs.waybar.enable on the NixOS side so that
  # a single place owns the package, the config and the service. systemd.enable
  # gives a unit with ConditionEnvironment=WAYLAND_DISPLAY and an
  # X-Reload-Triggers on the config, so edits reload the bar on switch.
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 8;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "pulseaudio"
        "backlight"
        "battery"
        "network"
        "tray"
        "clock"
      ];

      "hyprland/workspaces".on-click = "activate";
      "hyprland/window" = {
        max-length = 60;
        separate-outputs = true;
      };

      # Plain text labels rather than nerd-font glyphs, so the bar is readable
      # before you start tuning it. You have FiraCode and DroidSansMono Nerd Font
      # installed (see fonts.packages) if you'd rather swap in icons.
      pulseaudio = {
        format = "vol {volume}%";
        format-muted = "muted";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      # No `device` set — waybar autodetects, which differs between the two
      # machines. Only meaningful on the thinkpad.
      backlight.format = "bright {percent}%";

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "bat {capacity}%";
        format-charging = "chg {capacity}%";
        format-plugged = "ac {capacity}%";
      };

      network = {
        format-wifi = "{essid} {signalStrength}%";
        format-ethernet = "eth";
        format-disconnected = "offline";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      tray.spacing = 10;
    };

    style = ''
      * {
        font-family: "FiraCode Nerd Font", monospace;
        font-size: 12px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background: rgba(26, 26, 26, 0.9);
        color: #e6e6e6;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: #888888;
      }

      /* accents match the hyprland active-border gradient */
      #workspaces button.active {
        color: #33ccff;
        box-shadow: inset 0 -2px #33ccff;
      }

      #workspaces button.urgent {
        color: #00ff99;
      }

      #clock,
      #battery,
      #backlight,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
      }

      #battery.warning {
        color: #ffcc00;
      }

      #battery.critical {
        color: #ff5555;
      }
    '';
  };
}
