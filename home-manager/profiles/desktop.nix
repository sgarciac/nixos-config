# User config for graphical machines. Pulled in by nixos/profiles/desktop.nix.
{ inputs, pkgs, ... }:

let
  # github:numtide/llm-agents.nix — 145 packaged LLM coding agents.
  #
  # Taken from the flake's own `packages` output, which is built against ITS
  # pinned nixpkgs-unstable, NOT our nixpkgs. That is deliberate and is what
  # upstream recommends: the flake is only tested against that pin, and their
  # README states that pointing it at a stable branch like ours "will break
  # eventually". The cost is a second nixpkgs evaluation; the benefit is that
  # the numtide binary cache (configured in nixos/profiles/desktop.nix) actually
  # hits, instead of rebuilding everything locally.
  #
  # This is also why there is no `llm-agents.inputs.nixpkgs.follows` in
  # flake.nix, and why overlays.shared-nixpkgs is not used.
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

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
    # Emacs with packages - user manages .emacs.d, nix provides packages
    ../modules/emacs.nix
  ];

  #-------------------------------------------------------------------
  # Packages
  #-------------------------------------------------------------------

  # Binaries that modules/hyprland.nix references by name. Without these the
  # matching keybind fails silently — Hyprland just execs the command and
  # nothing happens.
  #
  # waybar, hyprpaper, hyprlock, nm-applet and emacs are absent on purpose: the
  # modules further down install them.
  home.packages = with pkgs; [
    kdePackages.dolphin # SUPER + E (fileManager)

    brightnessctl # XF86MonBrightness{Up,Down}
    playerctl # XF86Audio{Next,Prev,Play,Pause}

    kdePackages.kate
    #  thunderbird
  ]
  ++ [
    # LLM coding agents. Add more by name — `nix flake show github:numtide/llm-agents.nix`
    # lists all 145, or see the tables in their README. Notable ones:
    # opencode, codex, gemini-cli, qwen-code, crush, goose-cli, copilot-cli,
    # ccusage (token spend), ccstatusline (statusline for claude-code).
    llmAgents.claude-code
    llmAgents.pi
  ];



  #-------------------------------------------------------------------
  # Theming
  #-------------------------------------------------------------------

  # Replaces both the bibata-cursors system package and the hand-written
  # XCURSOR_THEME/XCURSOR_SIZE env vars: one option feeds the X11, GTK and
  # ~/.icons cursor config so every toolkit agrees.
  #
  # modules/hyprland.nix still sets XCURSOR_* via hl.env, because Hyprland reads
  # its own env block rather than the session variables. Keep the values here and
  # there in sync.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # This is what retires nwg-look. Note these two are MY choice, not a migration
  # of whatever you had set imperatively — change them if you had something else.
  # Adwaita-dark ships inside gnome-themes-extra.
  #
  # cursorTheme is intentionally not set here: home.pointerCursor above already
  # writes the GTK cursor settings, and setting both would conflict.
  gtk = {
    enable = true;

    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    # Set explicitly to silence the state-version deprecation warning. The
    # default is gated on stateVersion >= 26.05, where it becomes null.
    #
    # Adopting null on purpose: gtk4.theme works by @import-ing the theme's
    # gtk-4.0/gtk.css into ~/.config/gtk-4.0/gtk.css, which the module itself
    # flags as an unsupported workaround that "may cause issues with some apps"
    # — and Adwaita-dark may not even ship that file. GTK4/libadwaita apps
    # follow the dark preference below instead, which is the supported route.
    gtk4 = {
      theme = null;
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  # Makes Qt apps — kate and dolphin here — follow the GTK theme above instead of
  # needing a second theme config. Valid names: gtk3, gnome, adwaita, lxqt,
  # qtct, kde.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  #-------------------------------------------------------------------
  # Terminal
  #-------------------------------------------------------------------

  programs.kitty = {
    enable = true; # required for the default Hyprland config

    # The font itself is installed system-wide via fonts.packages in
    # nixos/profiles/desktop.nix.
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };

    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      window_padding_width = 4;
      confirm_os_window_close = 0;
    };
  };

  #-------------------------------------------------------------------
  # Firefox
  #-------------------------------------------------------------------

  programs.firefox = {
    enable = true;

    # Set explicitly to silence the state-version deprecation warning without
    # touching home.stateVersion. The default is gated on stateVersion >= 26.05,
    # where it becomes "${config.xdg.configHome}/mozilla/firefox".
    #
    # Keeping the legacy path means your existing profile — bookmarks, history,
    # logins — is found where it already is. To adopt the XDG path later, move the
    # directory FIRST and then change this:
    #   mv ~/.mozilla/firefox ~/.config/mozilla/firefox && rmdir ~/.mozilla
    configPath = ".mozilla/firefox";

    # Enterprise policies apply to *every* profile, which is exactly what we want
    # here: no `profiles.*` is declared, because declaring one would rewrite
    # profiles.ini and change which profile is default — hiding your existing
    # bookmarks, history and logins behind a fresh empty profile.
    policies = {
      ExtensionSettings = {
        # 1Password. The GUID and the AMO slug come from Mozilla's addons API,
        # not from memory. force_installed means Firefox fetches and enables it
        # on start, and you cannot accidentally remove it from the UI.
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  #-------------------------------------------------------------------
  # Launcher (SUPER + R)
  #-------------------------------------------------------------------

  # Replaces hyprlauncher, which at v0.1.6 has no theming whatsoever — its entire
  # config surface is 12 options, of which only `ui:window_size` is visual.
  #
  # Colours deliberately reuse the same accents as the Hyprland border gradient
  # and the waybar CSS below (#33ccff / #00ff99 on #1a1a1a), and `radius` matches
  # decoration.rounding, so the launcher looks like part of the same desktop.
  # Note fuzzel takes colours as RRGGBBAA hex with no leading '#'.
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "FiraCode Nerd Font:size=12";
        icon-theme = "Adwaita"; # matches gtk.iconTheme above
        terminal = "kitty"; # for .desktop entries with Terminal=true
        layer = "overlay";
        width = 45;
        lines = 12;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 8;
      };

      border = {
        width = 2;
        radius = 10;
      };

      colors = {
        background = "1a1a1aee";
        text = "e6e6e6ff";
        match = "33ccffff";
        selection = "33ccff33";
        selection-text = "ffffffff";
        selection-match = "00ff99ff";
        border = "33ccffff";
      };
    };
  };

  #-------------------------------------------------------------------
  # 1Password SSH agent
  #-------------------------------------------------------------------

  # Points ssh at 1Password's agent socket instead of ssh-agent, so your keys
  # live in 1Password and every use prompts for approval.
  #
  # This lives in the desktop profile because the agent is provided by the
  # 1Password *desktop app* (programs._1password-gui in
  # nixos/profiles/desktop.nix) — there is no agent on a headless host.
  #
  # ONE STEP IS NOT DECLARATIVE: the agent has to be switched on inside the app,
  # under Settings -> Developer -> "Use the SSH agent". That toggle is stored in
  # 1Password's own config, so nix cannot set it. Until you flip it once by hand,
  # the socket below won't exist and ssh will fail with "Error connecting to
  # agent: No such file or directory".
  programs.ssh = {
    enable = true;

    # Defaults to true and warns on every build that it is going away. The values
    # it sets (ForwardAgent no, Compression no, ControlMaster no, ...) are already
    # OpenSSH's own defaults, so turning it off changes nothing but silences the
    # warning. If you want them back explicitly, use programs.ssh.settings."*".
    enableDefaultConfig = false;

    matchBlocks."*".identityAgent = "~/.1password/agent.sock";
  };

  # Optionally restrict *which* keys the agent offers, and in what order, via
  # ~/.config/1Password/ssh/agent.toml. Left unmanaged on purpose: with no such
  # file 1Password offers every SSH key you have, which is almost certainly what
  # you want to start with. To pin it down declaratively:
  #
  # xdg.configFile."1Password/ssh/agent.toml".text = ''
  #   [[ssh-keys]]
  #   vault = "Private"
  # '';

  #-------------------------------------------------------------------
  # Session services
  #-------------------------------------------------------------------

  # Replaces the bare `nm-applet` exec that used to be in the hyprland.start
  # hook, so it gets a real unit bound to the session target. Needs waybar's
  # tray module (configured below) to be visible.
  services.network-manager-applet.enable = true;

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

  # Screen locker, driven by hypridle below. `path = "screenshot"` blurs whatever
  # was on screen rather than needing a separate lock image.
  programs.hyprlock = {
    enable = true;

    settings = {
      general.hide_cursor = true;

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          position = "0, -80";
          outline_thickness = 2;
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "<i>Password...</i>";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 64;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Idle daemon. This is the half that was missing before: the NixOS module was
  # running hypridle with no config file at all, so it did nothing.
  #
  # `loginctl lock-session` rather than calling hyprlock directly, so that
  # anything else asking systemd to lock the session takes the same path.
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300; # 5 min -> lock
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330; # 5.5 min -> screen off
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Deliberately no suspend listener: aorus and thinkpad share this profile
        # and silently suspending a desktop is obnoxious. Add one per-host if you
        # want it on the laptop only:
        # { timeout = 1800; on-timeout = "systemctl suspend"; }
      ];
    };
  };

  #-------------------------------------------------------------------
  # Bar
  #-------------------------------------------------------------------

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
