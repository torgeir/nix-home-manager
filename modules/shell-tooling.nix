{ config, lib, pkgs, ... }:

let cfg = config.programs.t-shell-tooling;
in {

  options.programs.t-shell-tooling.enable =
    lib.mkEnableOption "Enable useful shell tooling";

  config = lib.mkIf cfg.enable {

    programs.jq = { enable = true; };

    programs.fzf = { enable = true; };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    home.packages = with pkgs; [
      (ripgrep.override { withPCRE2 = true; })
      eza
      fd
      bat
      gawk
      htop
      btop
      watch
    ];
  };

}
