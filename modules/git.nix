{ config, lib, pkgs, ... }:

let
  cfg = config.programs.t-git;
  dotfiles = builtins.fetchGit {
    url = "https://github.com/torgeir/dotfiles";
    rev = "0ef8a92523ca9d463d54bcd8d1afacd526a4b6de";
  };
in {
  options.programs.t-git.enable = lib.mkEnableOption "Enable git configuration";
  options.programs.t-git.ghPackage = lib.mkPackageOption pkgs "gh" {
    default = "gh";
    example = "pkgs.unstable.gh";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "torgeir";
      userEmail = "torgeir.thoresen@gmail.com";
    };

    home.packages = with pkgs; [ cfg.ghPackage delta difftastic ];

    home.file.".gitconfig".source = dotfiles + "/gitconfig";
  };
}
