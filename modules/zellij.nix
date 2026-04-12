{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-zellij;
in {
  options.programs.t-zellij.enable =
    lib.mkEnableOption "Enable zellij configuration";

  config = lib.mkIf cfg.enable {

    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    home.packages = [ pkgs.zellij ];

    home.file.".config/zellij/config.kdl".text = ''
      default_layout "torg"
      default_mode "locked"
      default_shell "${config.programs.zsh.package}/bin/zsh"
      show_startup_tips false
      show_release_notes false
      theme "catppuccin-mocha"

      keybinds {
        locked {
          unbind "Ctrl g"
          bind "Ctrl b" { SwitchToMode "normal"; }
          bind "Ctrl Left" { GoToPreviousTab; }
          bind "Ctrl Right" { GoToNextTab; }
          bind "Ctrl Alt Up"    { MoveFocus "Up";    SwitchToMode "locked"; }
          bind "Ctrl Alt Down"  { MoveFocus "Down";  SwitchToMode "locked"; }
          bind "Ctrl Alt Left"  { MoveFocus "Left";  SwitchToMode "locked"; }
          bind "Ctrl Alt Right" { MoveFocus "Right"; SwitchToMode "locked"; }
        }
        normal {
          unbind "Ctrl g"
          unbind "Ctrl b"
          bind "Ctrl c" { SwitchToMode "locked"; }
          bind "," { SwitchToMode "renametab"; TabNameInput 0; }
          bind "Space" { NextSwapLayout; }
          bind "z" { ToggleFocusFullscreen; SwitchToMode "normal"; }
          bind "p" { GoToPreviousTab; SwitchToMode "normal"; }
          bind "n" { GoToNextTab; SwitchToMode "normal"; }
          bind "d" { Detach; }
          bind "c" { NewTab;            SwitchToMode "locked"; }
          bind "e" { EditScrollback;    SwitchToMode "locked"; }
          bind "s" { NewPane "Down";    SwitchToMode "locked"; }
          bind "v" { NewPane "Right";   SwitchToMode "locked"; }
          bind "h" { MoveFocus "Left";  SwitchToMode "locked"; }
          bind "l" { MoveFocus "Right"; SwitchToMode "locked"; }
          bind "j" { MoveFocus "Down";  SwitchToMode "locked"; }
          bind "k" { MoveFocus "Up";    SwitchToMode "locked"; }
        }
        shared_except "locked" {
          bind "Esc" { SwitchToMode "locked"; }
        }
      }
      scrollback_editor "et"
    '';
    home.file.".config/zellij/layouts/torg.kdl".text = ''
      layout {
        pane size=1 borderless=true {
          plugin location="zellij:tab-bar"
        }
        pane
        pane size=2 borderless=true {
          plugin location="zellij:status-bar"
        }
      }
    '';
    home.file.".config/zellij/themes/catppuccin.kdl".text = ''
      themes {
        catppuccin-mocha {
          bg "#585b70"
          fg "#cdd6f4"
          red "#f38ba8"
          green "#a6e3a1"
          blue "#89b4fa"
          yellow "#f9e2af"
          magenta "#f5c2e7"
          orange "#fab387"
          cyan "#89dceb"
          black "#223"
          white "#cdd6f4"
        }
      }
    '';
  };

}
