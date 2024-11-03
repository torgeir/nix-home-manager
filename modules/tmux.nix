{ config, lib, pkgs, ... }:

let
  cfg = config.programs.t-tmux;
  dotfiles = builtins.fetchGit {
    url = "https://github.com/torgeir/dotfiles";
    rev = "957bc71445f09fd7ddfb05aca76b9390bb81b9de";
  };
in {
  options.programs.t-tmux.enable =
    lib.mkEnableOption "Enable tmux configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ tmux ];
    home.file.".tmux.conf".source = dotfiles + "/tmux.conf";
  };
}
