{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-terminal.alacritty;
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
      ".config/alacritty/alacritty-toggle-appearance" = {
        text = ''
          #!/usr/bin/env bash
          cd ${config.xdg.configHome}/alacritty/
          darkmode=$(osascript -e 'tell application "System Events" to get dark mode of appearance preferences')
          if [ "true" = "$darkmode" ]; then
            cp -f alacritty-dark.toml alacritty.toml
          else
            cp -f alacritty-light.toml alacritty.toml
          fi
        '';
        executable = true;
      };

      ".config/alacritty/alacritty-toggle-appearance".onChange = ''
        #!/usr/bin/env bash
        cd ${config.xdg.configHome}/alacritty/
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

    home.packages = [
      (pkgs.writeShellScriptBin "alacritty-open" ''
        input="$1"
        # /some/path/file.kt
        if [[ $input =~ (([^/]+/)*[^.]+\.[^ ]{1,4}) ]]; then 
          file_path="''${BASH_REMATCH[1]}"
          /etc/profiles/per-user/torgeir/bin/emacsclient "$file_path"
        # detekt output /absolute/path/file:123:1
        elif [[ $input =~ (.*):([0-9]+):([0-9]+): ]]; then
          file_path="''${BASH_REMATCH[1]}"
          line_number="''${BASH_REMATCH[2]}"
          column="''${BASH_REMATCH[3]}"
          encoded_path=$(echo "$file_path" | sed 's/ /%20/g')
          open "idea://open?file=$encoded_path&line=$line_number&column=$column"
        else
          echo "Error: Dunno how to open, could not parse the input, got: $input"
          exit 1
        fi
      '')

      (pkgs.writeShellScriptBin "alacritty-open-folder" ''
        case $(uname) in
          Linux)
            thunar "$1"
            swaymsg "[app_id=thunar]" focus
            ;;
          Darwin)
            open -a Finder -- "$1"
            ;;
        esac
      '')

      (pkgs.writeShellScriptBin "alacritty-open-url" ''
        case $(uname) in
          Linux)
            xdg-open "$1"
            ;;
          Darwin)
            open -a Firefox\ Developer\ Edition -- "$1"
            ;;
        esac
      '')
    ];
  };

}
