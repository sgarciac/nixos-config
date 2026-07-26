{ config, lib, pkgs, ... }:

let
  inherit (lib.generators) mkLuaInline;

  #---------------------
  #---- MY PROGRAMS ----
  #---------------------

  # Set programs that you use
  terminal = "kitty";
  fileManager = "dolphin";
  menu = "hyprlauncher";

  # Sets "Windows" key as main modifier
  mainMod = "SUPER";

  #-----------------
  #---- HELPERS ----
  #-----------------

  # hl.dsp.exec_cmd("<cmd>")
  exec = cmd: ''hl.dsp.exec_cmd(${builtins.toJSON cmd})'';

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

      # See https://wiki.hypr.land/Configuring/Basics/Monitors/
      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "auto";
      };

      #-------------------
      #---- AUTOSTART ----
      #-------------------

      # See https://wiki.hypr.land/Configuring/Basics/Autostart/
      #
      # Autostart necessary processes (like notifications daemons, status bars,
      # etc.) Or execute your favorite apps at launch like this:
      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd(${builtins.toJSON terminal})
              hl.exec_cmd("nm-applet")
              hl.exec_cmd("waybar & hyprpaper & firefox")
            end'')
        ];
      };

      #-------------------------------
      #---- ENVIRONMENT VARIABLES ----
      #-------------------------------

      # See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
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

      # Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
      bind = [
        (mkBind "${mainMod} + Q" (exec terminal))
        (mkBind "${mainMod} + C" "hl.dsp.window.close()")
        (mkBind "${mainMod} + M" (exec "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
        (mkBind "${mainMod} + E" (exec fileManager))
        (mkBind "${mainMod} + V" ''hl.dsp.window.float({ action = "toggle" })'')
        (mkBind "${mainMod} + R" (exec menu))
        (mkBind "${mainMod} + P" "hl.dsp.window.pseudo()")
        (mkBind "${mainMod} + J" ''hl.dsp.layout("togglesplit")'') # dwindle only

        # Move focus with mainMod + arrow keys
        (mkBind "${mainMod} + left" ''hl.dsp.focus({ direction = "left" })'')
        (mkBind "${mainMod} + right" ''hl.dsp.focus({ direction = "right" })'')
        (mkBind "${mainMod} + up" ''hl.dsp.focus({ direction = "up" })'')
        (mkBind "${mainMod} + down" ''hl.dsp.focus({ direction = "down" })'')
      ]
      ++ workspaceBinds
      ++ [
        # Example special workspace (scratchpad)
        (mkBind "${mainMod} + S" ''hl.dsp.workspace.toggle_special("magic")'')
        (mkBind "${mainMod} + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')

        # Scroll through existing workspaces with mainMod + scroll
        (mkBind "${mainMod} + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (mkBind "${mainMod} + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')

        # Move/resize windows with mainMod + LMB/RMB and dragging
        (mkMouseBind "${mainMod} + mouse:272" "hl.dsp.window.drag()")
        (mkMouseBind "${mainMod} + mouse:273" "hl.dsp.window.resize()")

        # Laptop multimedia keys for volume and LCD brightness
        (mkLockedRepeatBind "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
        (mkLockedRepeatBind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
        (mkLockedRepeatBind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
        (mkLockedRepeatBind "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
        (mkLockedRepeatBind "XF86MonBrightnessUp" (exec "brightnessctl -e4 -n2 set 5%+"))
        (mkLockedRepeatBind "XF86MonBrightnessDown" (exec "brightnessctl -e4 -n2 set 5%-"))

        # Requires playerctl
        (mkLockedBind "XF86AudioNext" (exec "playerctl next"))
        (mkLockedBind "XF86AudioPause" (exec "playerctl play-pause"))
        (mkLockedBind "XF86AudioPlay" (exec "playerctl play-pause"))
        (mkLockedBind "XF86AudioPrev" (exec "playerctl previous"))
      ];

      #---------------
      #--- GESTURES --
      #---------------

      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

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

      # Example window rules that are useful
      window_rule = [
        {
          # Ignore maximize requests from all apps. You'll probably like this.
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
        # Hyprland-run windowrule
        {
          name = "move-hyprland-run";
          match.class = "hyprland-run";

          move = "20 monitor_h-120";
          float = true;
        }

        # "Smart gaps" companions to the workspace_rule entries above
        # { name = "no-gaps-wtv1"; match = { float = false; workspace = "w[tv1]"; }; border_size = 0; rounding = 0; }
        # { name = "no-gaps-f1";   match = { float = false; workspace = "f[1]"; };   border_size = 0; rounding = 0; }
      ];

      # layer_rule = [
      #   { name = "no-anim-overlay"; match.namespace = "^my-overlay$"; no_anim = true; }
      # ];
    };
  };
}
