{ config, lib, pkgs, ... }:

let
  inherit (lib.generators) mkLuaInline;

  #---------------------
  #---- MY PROGRAMS ----
  #---------------------

  # Set programs that you use
  terminal = "kitty";
  fileManager = "dolphin";
  editor = "kate";
  calculator = "gnome-calculator";
  browser = "firefox";

  # Noctalia command prefix
  noctalia = "noctalia msg ";

  # Sets "Windows" key as main modifier
  mainMod = "SUPER";

  #-----------------
  #---- HELPERS ----
  #-----------------

  # hl.dsp.exec_cmd("<cmd>")
  exec = cmd: ''hl.dsp.exec_cmd(${builtins.toJSON cmd})'';

  # Call Noctalia command
  noct = cmd: exec (noctalia + cmd);

  # hl.bind("<key>", <dispatcher>)
  mkBind = key: dispatcher: { _args = [ key (mkLuaInline dispatcher) ]; };

  # hl.bind("<key>", <dispatcher>, { <flags> })
  mkBindWith = flags: key: dispatcher: {
    _args = [ key (mkLuaInline dispatcher) flags ];
  };

  mkMouseBind = mkBindWith { mouse = true; };
  mkLockedBind = mkBindWith { locked = true; };
  mkLockedRepeatBind = mkBindWith {
    locked = true;
    repeating = true;
  };

  # Switch workspaces with mainMod + [0-9]
  # Move active window to a workspace with mainMod + SHIFT + [0-9]
  workspaceBinds = lib.concatMap (
    i:
    let
      key = if i == 10 then "0" else toString i; # 10 maps to key 0
    in
    [
      (mkBind "${mainMod} + ${key}" "hl.dsp.focus({ workspace = ${toString i} })")
      (mkBind "${mainMod} + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString i} })")
    ]
  ) (lib.range 1 10);
in
{
  wayland.windowManager.hyprland = {
    enable = true;

    # Generate ~/.config/hypr/hyprland.lua instead of hyprland.conf.
    # Required explicitly here: the default is still "hyprlang" until
    # home.stateVersion >= "26.05".
    configType = "lua";

    # Each attribute below maps to an `hl.<name>(...)` call; list values
    # generate one call per element. `_args` generates a multi-argument call.
    # Attributes matching `importantPrefixes` (which includes "curve") are
    # emitted first, so curves are always defined before the animations that
    # reference them.
    settings = {

      #------------------
      #---- MONITORS ----
      #------------------

      # Monitors are declared per host, NOT here — see home-manager/hosts/.
      # This module is shared by aorus and thinkpad, which need different modes
      # and scales, and `settings.monitor` set in two places would collide rather
      # than override.
      #
      # See https://wiki.hypr.land/Configuring/Basics/Monitors/

      #-------------------
      #---- AUTOSTART ----
      #-------------------

      # See https://wiki.hypr.land/Configuring/Basics/Autostart/
      #
      # Autostart necessary processes (like notifications daemons, status bars,
      # etc.) Or execute your favorite apps at launch like this:


      #-------------------------------
      #---- ENVIRONMENT VARIABLES ----
      #-------------------------------

      # See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
      #
      # These stay here even though home.pointerCursor (in profiles/desktop.nix)
      # also configures the cursor: Hyprland reads its own env block rather than
      # the session variables, so the compositor's own cursor needs this. Keep the
      # theme name and size in sync with home.pointerCursor.
      env = [
        {
          _args = [
            "XCURSOR_SIZE"
            "24"
          ];
        }
        # { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
        # { _args = [ "HYPRCURSOR_THEME" "Bibata-Modern-Classic" ]; }
        {
          _args = [
            "XCURSOR_THEME"
            "Bibata-Modern-Classic"
          ];
        }
      ];

      #-----------------------
      #---- LOOK AND FEEL ----
      #-----------------------

      # Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
      config = {
        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;

          col = {
            active_border = {
              colors = [
                "rgba(33ccffee)"
                "rgba(00ff99ee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(595959aa)";
          };

          # Set to true to enable resizing windows by clicking and dragging on
          # borders and gaps
          resize_on_border = false;

          # Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
          # before you turn this on
          allow_tearing = false;

          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            # Nix has no hex literals, so inline it as raw Lua
            color = mkLuaInline "0xee1a1a1a";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        animations = {
          enabled = true;
        };

        # See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
        dwindle = {
          preserve_split = true; # You probably want this
        };

        # See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
        master = {
          new_status = "master";
        };

        # See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
        scrolling = {
          fullscreen_on_one_column = true;
        };

        #----------------
        #----  MISC  ----
        #----------------

        misc = {
          force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
        };

        #---------------
        #---- INPUT ----
        #---------------

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "ctrl:nocaps";
          kb_rules = "";

          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

          touchpad = {
            natural_scroll = false;
          };
        };

        #-----------------------
        #----- PERMISSIONS -----
        #-----------------------

        # See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
        # Please note permission changes here require a Hyprland restart and are
        # not applied on-the-fly for security reasons
        #
        # ecosystem = {
        #   enforce_permissions = true;
        # };
      };

      # permission = [
      #   { _args = [ "/usr/(bin|local/bin)/grim" "screencopy" "allow" ]; }
      #   { _args = [ "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland" "screencopy" "allow" ]; }
      #   { _args = [ "/usr/(bin|local/bin)/hyprpm" "plugin" "allow" ]; }
      # ];

      # Default curves and animations, see
      # https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [ 0.23 1 ]
                [ 0.32 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [ 0.65 0.05 ]
                [ 0.36 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [ 0 0 ]
                [ 1 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [ 0.5 0.5 ]
                [ 0.75 1 ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [ 0.15 0 ]
                [ 0.1 1 ]
              ];
            }
          ];
        }

        # Default springs
        {
          _args = [
            "easy"
            {
              type = "spring";
              mass = 1;
              stiffness = 71.2633;
              dampening = 15.8273644;
            }
          ];
        }
      ];

      animation = [
        { leaf = "global";        enabled = true; speed = 10;   bezier = "default"; }
        { leaf = "border";        enabled = true; speed = 5.39; bezier = "easeOutQuint"; }
        { leaf = "windows";       enabled = true; speed = 4.79; spring = "easy"; }
        { leaf = "windowsIn";     enabled = true; speed = 4.1;  spring = "easy";         style = "popin 87%"; }
        { leaf = "windowsOut";    enabled = true; speed = 1.49; bezier = "linear";       style = "popin 87%"; }
        { leaf = "fadeIn";        enabled = true; speed = 1.73; bezier = "almostLinear"; }
        { leaf = "fadeOut";       enabled = true; speed = 1.46; bezier = "almostLinear"; }
        { leaf = "fade";          enabled = true; speed = 3.03; bezier = "quick"; }
        { leaf = "layers";        enabled = true; speed = 3.81; bezier = "easeOutQuint"; }
        { leaf = "layersIn";      enabled = true; speed = 4;    bezier = "easeOutQuint"; style = "fade"; }
        { leaf = "layersOut";     enabled = true; speed = 1.5;  bezier = "linear";       style = "fade"; }
        { leaf = "fadeLayersIn";  enabled = true; speed = 1.79; bezier = "almostLinear"; }
        { leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear"; }
        { leaf = "workspaces";    enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
        { leaf = "workspacesIn";  enabled = true; speed = 1.21; bezier = "almostLinear"; style = "fade"; }
        { leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
        { leaf = "zoomFactor";    enabled = true; speed = 7;    bezier = "quick"; }
      ];

      # Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
      # "Smart gaps" / "No gaps when only"
      # uncomment all if you wish to use that.
      #
      # workspace_rule = [
      #   { workspace = "w[tv1]"; gaps_out = 0; gaps_in = 0; }
      #   { workspace = "f[1]";   gaps_out = 0; gaps_in = 0; }
      # ];

      #---------------------
      #---- KEYBINDINGS ----
      #---------------------

      # Keybindings inspired by CachyOS Hypr/Noctalia configuration
      # See https://wiki.hypr.land/Configuring/Basics/Binds/ for more
      bind = [
        # --- Window Management ---
        (mkBind "${mainMod} + Escape" (exec "hyprctl kill"))
        (mkBind "${mainMod} + Q" (exec terminal))
        (mkBind "${mainMod} + ALT + Space" ''hl.dsp.window.float({ action = "toggle" })'')
        (mkBind "${mainMod} + C" "hl.dsp.window.close()")
        (mkBind "${mainMod} + D" ''hl.dsp.window.fullscreen({ mode = 1 })'')
        (mkBind "${mainMod} + F" "hl.dsp.window.fullscreen()")
        (mkBind "${mainMod} + J" ''hl.dsp.layout("togglesplit")'')

        # Move focus with mainMod + arrow keys
        (mkBind "${mainMod} + Left" ''hl.dsp.focus({ direction = "left" })'')
        (mkBind "${mainMod} + Right" ''hl.dsp.focus({ direction = "right" })'')
        (mkBind "${mainMod} + Up" ''hl.dsp.focus({ direction = "up" })'')
        (mkBind "${mainMod} + Down" ''hl.dsp.focus({ direction = "down" })'')

        # Alt+Tab to cycle windows
        (mkBind "ALT + Tab" "hl.dsp.window.cycle_next()")
        (mkBind "${mainMod} + Tab" (noct "window-switcher"))

        # --- Launchers & Panels (Noctalia) ---
        (mkBind "${mainMod} + Return" (exec terminal))
        (mkBind "${mainMod} + E" (exec fileManager))
        (mkBind "${mainMod} + T" (exec editor))
        (mkBind "${mainMod} + SHIFT + C" (exec calculator))
        (mkBind "${mainMod} + W" (exec browser))
        (mkBind "XF86Calculator" (exec calculator))

        # Noctalia panels
        (mkBind "${mainMod} + Z" (noct "settings-toggle"))
        (mkBind "${mainMod} + X" (noct "panel-toggle control-center"))
        (mkBind "${mainMod} + Space" (noct "panel-toggle launcher"))
        (mkBind "${mainMod} + period" (noct "panel-toggle launcher /emo"))
        (mkBind "${mainMod} + L" (noct "session lock"))
        (mkBind "${mainMod} + ALT + C" (noct "panel-toggle session"))

        # --- Screenshot & Color Picker ---
        (mkBind "${mainMod} + P" (exec "hyprpicker -a -n"))
        (mkBind "Print" (noct "screenshot-region"))
        (mkBind "${mainMod} + Print" (noct "screenshot-fullscreen"))

        # --- Noctalia panels & utilities ---
        (mkBind "${mainMod} + SHIFT + W" (noct "panel-toggle wallpaper"))
        (mkBind "${mainMod} + V" (noct "panel-toggle clipboard"))
        (mkBind "${mainMod} + A" (noct "panel-toggle control-center notifications"))
      ]
      ++ workspaceBinds
      ++ [
        # --- Special Workspace (scratchpad) ---
        (mkBind "${mainMod} + S" ''hl.dsp.workspace.toggle_special()'')
        (mkBind "${mainMod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special" })'')

        # --- Move Windows ---
        (mkBind "${mainMod} + SHIFT + Up" ''hl.dsp.window.move({ direction = "u" })'')
        (mkBind "${mainMod} + SHIFT + Down" ''hl.dsp.window.move({ direction = "d" })'')
        (mkBind "${mainMod} + SHIFT + Left" ''hl.dsp.window.move({ direction = "l" })'')
        (mkBind "${mainMod} + SHIFT + Right" ''hl.dsp.window.move({ direction = "r" })'')

        # Scroll through existing workspaces with mainMod + scroll
        (mkBind "${mainMod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (mkBind "${mainMod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

        # Move/resize windows with mainMod + LMB/RMB and dragging
        (mkMouseBind "${mainMod} + mouse:272" "hl.dsp.window.drag()")
        (mkMouseBind "${mainMod} + mouse:273" "hl.dsp.window.resize()")

        # --- Hardware Controls (Noctalia) ---
        # Audio
        (mkLockedRepeatBind "XF86AudioRaiseVolume" (noct "volume-up"))
        (mkLockedRepeatBind "XF86AudioLowerVolume" (noct "volume-down"))
        (mkLockedRepeatBind "XF86AudioMute" (noct "volume-mute"))
        (mkLockedRepeatBind "XF86AudioMicMute" (noct "mic-mute"))

        # Media
        (mkLockedBind "XF86AudioPlay" (noct "media toggle"))
        (mkLockedBind "XF86AudioPause" (noct "media toggle"))
        (mkLockedBind "XF86AudioNext" (noct "media next"))
        (mkLockedBind "XF86AudioPrev" (noct "media previous"))

        # Brightness
        (mkLockedRepeatBind "XF86MonBrightnessUp" (noct "brightness-up"))
        (mkLockedRepeatBind "XF86MonBrightnessDown" (noct "brightness-down"))
      ];

      #---------------
      #--- GESTURES --
      #---------------

      # 4-finger horizontal swipe: switch workspace
      # 3-finger swipe: window actions (close, fullscreen, float)
      gesture = [
        { fingers = 4; direction = "horizontal"; action = "workspace"; }
        { fingers = 3; direction = "down";       action = "close"; }
        { fingers = 3; direction = "up";          action = "fullscreen"; }
        { fingers = 3; direction = "left";       action = "float"; }
      ];

      # Example per-device config
      # See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      #------------------------------
      #---- WINDOWS AND WORKSPACES --
      #------------------------------

      # See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
      # and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

      # Window rules
      window_rule = [
        {
          # Ignore maximize requests from all apps
          name = "suppress-maximize-events";
          match.class = ".*";
          suppress_event = "maximize";
        }
        {
          # Fix some dragging issues with XWayland
          name = "fix-xwayland-drags";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }

        # Picture-in-Picture for video players
        {
          name = "picture-in-picture";
          match.title = "^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$";
          float = true;
          keep_aspect_ratio = true;
          size = [ "max(monitor_w, monitor_h)*0.25" "min(monitor_w, monitor_h)*0.25" ];
          pin = true;
        }

        # Float utility windows
        { name = "float-utilities"; match.class = "^(kvantummanager|qt[56]ct|nwg-look)$"; float = true; }
        { name = "float-system"; match.class = "^(org\.pulseaudio\.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$"; float = true; }
        { name = "float-modals"; match.title = "^(Winetricks.*|Protontricks.*)$"; float = true; }

        # Float common modals (file dialogs, etc.)
        {
          name = "float-modals";
          match.title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$";
          float = true;
        }
        {
          name = "float-dialogs";
          match.class = "^([Xx]dg-desktop-portal-gtk)$";
          float = true;
        }
        { name = "float-xdg"; match.title = "^(File Upload|Choose wallpaper|Library)(.*)$"; float = true; }
        { name = "float-dialogs-class"; match.class = "^(.*dialog.*)$"; float = true; }
      ];

      # Noctalia layer rules - proper blur/animation handling
      layer_rule = [
        {
          name = "noctalia-blur";
          match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
          no_anim = true;
          ignore_alpha = 0.5;
          blur = true;
          blur_popups = true;
        }
      ];
    };
  };
}
