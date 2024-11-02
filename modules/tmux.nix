{ config, lib, pkgs, ... }:

let
  cfg = config.programs.t-tmux;
  dotfiles = builtins.fetchGit {
    url = "https://github.com/torgeir/dotfiles";
    rev = "4d6ffad78640bfe606c24933ba9e58bd330e7cb1";
  };
in {
  options.programs.t-tmux.enable =
    lib.mkEnableOption "Enable tmux configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ tmux ];
    home.file.".tmux.conf".source = dotfiles + "/tmux.conf";
  };
}
