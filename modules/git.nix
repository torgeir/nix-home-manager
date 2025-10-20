{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-git;
in {
  options.programs.t-git.enable = lib.mkEnableOption "Enable git configuration";
  options.programs.t-git.ghPackage = lib.mkPackageOption pkgs "gh" {
    default = "gh";
    example = "pkgs.unstable.gh";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "torgeir";
          email = "torgeir.thoresen@gmail.com";
        };
      };
    };

    home.packages = with pkgs; [ cfg.ghPackage delta difftastic ];

    home.file.".gitconfig".source = dotfiles + "/gitconfig";
  };
}
