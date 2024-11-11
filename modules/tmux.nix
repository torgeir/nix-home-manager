{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-tmux;
in {
  options.programs.t-tmux.enable =
    lib.mkEnableOption "Enable tmux configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ tmux ];
    home.file.".tmux.conf".source = dotfiles + "/tmux.conf";
  };
}
