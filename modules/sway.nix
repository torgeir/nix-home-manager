{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-sway;
in {

  # sway also needs
  #   hardware.opengl.enable = true;
  #   hardware.opengl.driSupport = true;
  #   security.polkit.enable = true;

  options.programs.t-sway.enable =
    lib.mkEnableOption "Enable sway configuration.";

  options.programs.t-sway.extraConfig = lib.mkOption {
    type = lib.types.str;
    default = "";
    example = ''
      output * {
        resolution 2560x1440
      }
    '';
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

      # media keys
      playerctl

      # sensors
      inxi
      i3status-rust

    ];

    home.file.".config/sway".source = dotfiles + "/config/sway";
    home.file.".config/mako".source = dotfiles + "/config/mako";
    home.file.".config/dunst".source = dotfiles + "/config/dunst";
    home.file.".config/i3status-rust".source = dotfiles
      + "/config/i3status-rust";

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "alacritty";
        assigns = { "workspace 1" = [{ app_id = "firefox"; }]; };
        startup = [{ command = "firefox"; }];
      };
      extraConfig = ''
        input type:keyboard {
          xkb_file ${./sway/xkb/symbols/custom}
        }
      '' + cfg.extraConfig;
    };

  };
}
