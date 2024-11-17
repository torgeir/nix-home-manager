{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-sway;
in {

  # sway also needs
  #   hardware.opengl.enable = true;
  #   security.polkit.enable = true;

  options.programs.t-sway.enable =
    lib.mkEnableOption "Enable sway configuration.";

  options.programs.t-sway.titlebar =
    lib.mkEnableOption "Enable sway titlebar.";

  options.programs.t-sway.extraConfig = lib.mkOption {
    type = lib.types.str;
    default = "";
    example = ''
      output * {
        resolution 2560x1440
      }
    '';
  };

  options.programs.t-sway.statusCommand = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    example = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config.toml";
    default = "${pkgs.i3status}/bin/i3status";
  };

  options.programs.t-sway.command = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    example = "${pkgs.sway}/bin/swaybar";
    default = "${pkgs.sway}/bin/swaybar";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      # screenshots
      grim
      slurp
      sway-contrib.grimshot
      swayimg

      # notifications
      mako
      libnotify

      # launcher
      tofi

      # bars
      i3status
      i3status-rust

      # media keys
      playerctl

      # sensors
      inxi
      i3status-rust
    ];

    home.file.".config/bg.jpg".source = dotfiles + "/bg.jpg";
    home.file.".config/mako".source = dotfiles + "/config/mako";
    home.file.".config/dunst".source = dotfiles + "/config/dunst";
    home.file.".config/i3status-rust".source = dotfiles
      + "/config/i3status-rust";
    home.file.".config/sway/keymap".source = ./config/sway/xkb/symbols/custom;
    home.file.".config/tofi/config".text = ''
      font=IosevkaTerm Nerd Font
      anchor = top
      width = 100%
      height = 30
      horizontal = true
      font-size = 14
      prompt-text = " run: "
      outline-width = 0
      border-width = 0
      background-color = #000000
      min-input-width = 120
      result-spacing = 15
      padding-top = 0
      padding-bottom = 0
      padding-left = 0
      padding-right = 0
    '';

    wayland.windowManager.sway = let
      browser = "firefox";
      terminal = "alacritty";
      filemanager = "thunar";
      opacity = "0.97";
    in {
      enable = true;
      checkConfig = false;
      config = {
        modifier = "Mod4";
        terminal = terminal;
        assigns = { "workspace 1" = [{ app_id = browser; }]; };
        startup = [
          { command = browser; }
          {
            command = ''
              exec swayidle -w \
                timeout 600 'swaylock -f -c 000000' \
                timeout 700 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
                before-sleep 'swaylock -f -c 000000'
            '';
          }
        ];
        input = { 
          "type:keyboard" = {
            xkb_file = "${config.xdg.configHome}/sway/keymap";
            xkb_options = "caps:none";
          };
          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "enabled";
            click_method = "button_areas";
          };
        };
        window = {
          titlebar = cfg.titlebar;
          commands = [
            {
              criteria.class = ".*";
              command = "opacity ${opacity}";
            }
            {
              criteria.app_id = ".*";
              command = "opacity ${opacity}";
            }
          ];
        };
        gaps = {
          inner = 10;
          outer = 0;
        };
        floating = { border = 0; };
        bars = [{
          position = "bottom";
          fonts = {
            names = [ "pango:IosevkaTerm Nerd Font" "FontAwesome" ];
            size = 11.0;
          };
          command = cfg.command;
          statusCommand = cfg.statusCommand;

          #colors = {
          #  separator = "#666666";
          #  background = "#222222";
          #  statusline = "#dddddd";
          #  focusedWorkspace = {
          #    background = "#0088CC";
          #    border = "#0088CC";
          #    text = "#ffffff";
          #  };
          #  activeWorkspace = {
          #    background = "#333333";
          #    border = "#333333";
          #    text = "#ffffff";
          #  };
          #  inactiveWorkspace = {
          #    background = "#333333";
          #    border = "#333333";
          #    text = "#888888";
          #  };
          #  urgentWorkspace = {
          #    background = "#2f343a";
          #    border = "#900000";
          #    text = "#ffffff";
          #  };
          #};

        }];
        keybindings = let
          meta = "Mod1";
          mod = "Mod4";
          swayfocus = pkgs.writeShellScript "swayfocus.sh" ''
            id=$(swaymsg -rt get_workspaces \
                | jq ".[] | select(.representation | contains(\"$1\")) | .focus[0]" \
                | head -n 1)
            swaymsg "[con_id=$id]" focus
          '';
        in {
          # quick run
          "${mod}+shift+Return" = "exec ${browser}";
          "${mod}+n" = "exec ${filemanager}";
          "${mod}+Ctrl+Return" = "exec ${terminal}";
          "${mod}+Return" = ''
            exec emacsclient --eval '\
              (if (frame-focus-state)\
              (with-current-buffer (buffer-name (window-buffer (frame-selected-window)))\
              (t/vterm-here))\
              (with-selected-frame (make-frame)\
              (let ((default-directory (t/read-file (t/user-file ".cur"))))\
              (+vterm/here t))))'
          '';

          # focus apps
          "${meta}+i" = "exec ${swayfocus} ${browser}";
          "${meta}+e" = "exec ${swayfocus} emacs";
          "${meta}+s" = "exec ${swayfocus} Slack";

          # focus arrows
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";
          "${mod}+Down" = "focus down";
          "${mod}+Left" = "focus left";

          # focus home row
          "${meta}+k" = "focus up";
          "${meta}+l" = "focus right";
          "${meta}+j" = "focus down";
          "${meta}+h" = "focus left";

          # move to workspace
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 0";

          # kill
          "${mod}+Shift+q" = "kill";

          # run
          "${mod}+Space" = "exec tofi-run | xargs swaymsg exec --";
          "${mod}+Shift+Space" = "exec tofi-drun --drun-launch=true";

          # exit
          "${mod}+Ctrl+e" = "exec 'swaymsg exit'";
          "${mod}+Ctrl+s" = "exec 'swaymsg suspend'";
          "${mod}+Ctrl+r" = "exec 'systemctl reboot'";
          "${mod}+Ctrl+p" = "exec 'systemctl poweroff'";
          "${mod}+Ctrl+l" = "exec 'swaylock -f -c 000000'";

          # reload sway
          "${mod}+Ctrl+c" = "reload";

          # Media buttons
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          # Move window
          "${meta}+Shift+k" = "move up";
          "${meta}+Shift+l" = "move right";
          "${meta}+Shift+j" = "move down";
          "${meta}+Shift+h" = "move left";
          # Ditto, super
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Left" = "move left";

          # Containers
          "${mod}+Shift+1" =
            "move container to workspace number 1; workspace 1";
          "${mod}+Shift+2" =
            "move container to workspace number 2; workspace 2";
          "${mod}+Shift+3" =
            "move container to workspace number 3; workspace 3";
          "${mod}+Shift+4" =
            "move container to workspace number 4; workspace 4";
          "${mod}+Shift+5" =
            "move container to workspace number 5; workspace 5";
          "${mod}+Shift+6" =
            "move container to workspace number 6; workspace 6";
          "${mod}+Shift+7" =
            "move container to workspace number 7; workspace 7";
          "${mod}+Shift+8" =
            "move container to workspace number 8; workspace 8";
          "${mod}+Shift+9" =
            "move container to workspace number 9; workspace 9";
          "${mod}+Shift+0" =
            "move container to workspace number 10; workspace 10";

          # layouts
          "${meta}+Shift+x" = "layout toggle all";
          "${meta}+Shift+s" = "layout toggle split";
          "${meta}+Shift+g" = "splith";
          "${meta}+Shift+v" = "splitv";

          # Maximize
          "${meta}+Shift+m" = "fullscreen";

          # Toggle the current focus between tiling and floating mode
          "${mod}+Shift+f" = "floating toggle";

          # Swap between tiling window and the floating window
          "${mod}+Ctrl+f" = "focus mode_toggle";

          # Move focus to the parent container
          "${meta}+Shift+p" = "focus parent";

          # Scratch
          "${mod}+Ctrl+m" = "move scratchpad";
          "${mod}+Ctrl+a" = "scratchpad show";

          # Resize
          "Ctrl+${mod}+Left" = "resize shrink width 100px";
          "Ctrl+${mod}+Down" = "resize grow height 100px";
          "Ctrl+${mod}+Up" = "resize shrink height 100px";
          "Ctrl+${mod}+Right" = "resize grow width 100px";

          # sticky
          "${mod}+p" = "sticky toggle; exec notify-send 'sticky'";

          # screenshot
          "${mod}+Ctrl+${meta}+s" =
            ''mode "Screenshot: (s)election|(d)isplay|(w)indow|(p)ixel value"'';
        };
        modes = {
          "Screenshot: (s)election|(d)isplay|(w)indow|(p)ixel value" = {
            s = ''
              exec grimshot save area \
                  $HOME/Dropbox/Screenshots/$(date +"%Y-%m-%dT%H:%M:%SZ_grim.png") \
                ; mode default
            '';
            d = ''
              exec grimshot save output \
                  $HOME/Dropbox/Screenshots/$(date +"%Y-%m-%dT%H:%M:%SZ_grim.png") \
                ; mode default
            '';
            w = ''
              exec grimshot save window \
                  $HOME/Dropbox/Screenshots/$(date +"%Y-%m-%dT%H:%M:%SZ_grim.png") \
                ; mode default
            '';
            p = ''
              exec grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- \
                ; mode default
            '';
            Escape = ''mode "default"'';
          };
        };
      };
      extraConfig = cfg.extraConfig;
    };
  };
}
