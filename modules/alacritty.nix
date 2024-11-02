{ config, lib, pkgs, ... }:

let
  cfg = config.programs.t-terminal.alacritty;
  dotfiles = builtins.fetchGit {
    url = "https://github.com/torgeir/dotfiles";
    rev = "01073b7a3b44885d5fa3f7c372560417a4d3f1ca";
  };
in {

  options.programs.t-terminal.alacritty.enable =
    lib.mkEnableOption "Enable alacritty configuration.";

  options.programs.t-terminal.alacritty.package =
    lib.mkPackageOption pkgs "alacritty" {
      default = "alacritty";
      example = "pkgs.unstable.alacritty";
    };

  config = lib.mkIf cfg.enable {

    programs.alacritty = {
      enable = true;
      package = cfg.package;
    };

    home.file = if pkgs.stdenv.isDarwin then {
      ".config/alacritty/main.toml".source = dotfiles
        + "/config/alacritty/main.toml";
      ".config/alacritty/alacritty-dark.toml".source = dotfiles
        + "/config/alacritty/alacritty-dark.toml";
      ".config/alacritty/alacritty-light.toml".source = dotfiles
        + "/config/alacritty/alacritty-light.toml";
      ".config/alacritty/catppuccin-mocha.toml".source = dotfiles
        + "/config/alacritty/catppuccin-mocha.toml";
      ".config/alacritty/catppuccin-latte.toml".source = dotfiles
        + "/config/alacritty/catppuccin-latte.toml";

      # hack to switch theme on macos only
      ".config/alacritty/alacritty-toggle-appearance".text = ''
        #!/usr/bin/env bash
        cd ${config.xdg.configHome}/alacritty/
        case $(uname) in
          Linux)
            darkmode=true
          ;;
          Darwin)
            darkmode=$(osascript -e 'tell application "System Events" to get dark mode of appearance preferences')
          ;;
        esac
        if [ "true" = "$darkmode" ]; then
          cp -f alacritty-dark.toml alacritty.toml
        else
          cp -f alacritty-light.toml alacritty.toml
        fi
      '';
      ".config/alacritty/alacritty-toggle-appearance".onChange = ''
        #!/usr/bin/env bash
        if [ ! -f alacritty.toml ]; then
          cp -f alacritty-dark.toml alacritty.toml
        fi
        sudo chown torgeir ${config.xdg.configHome}/alacritty/alacritty-toggle-appearance
        sudo chmod u+x ${config.xdg.configHome}/alacritty/alacritty-toggle-appearance
      '';
    } else {
      ".config/alacritty/catppuccin-mocha.toml".source = dotfiles
        + "/config/alacritty/catppuccin-mocha.toml";
      ".config/alacritty/alacritty.toml".source = dotfiles
        + "/config/alacritty/alacritty.toml";
      ".config/alacritty/main.toml".source = dotfiles
        + "/config/alacritty/main.toml";
    };
  };
}
