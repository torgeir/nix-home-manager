{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-shell-tooling;
in {

  options.programs.t-shell-tooling.enable =
    lib.mkEnableOption "Enable useful shell tooling";

  config = lib.mkIf cfg.enable {

    programs.jq = { enable = true; };

    programs.fzf = { enable = true; };
    home.file.".fzfrc".source = dotfiles + "/fzfrc";

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Iosevka" "IosevkaTerm" ]; })
      (ripgrep.override { withPCRE2 = true; })
      eza
      fd
      bat
      gawk
      htop
      btop
      watch
    ];
    home.file.".config/btop".source = dotfiles + "/config/btop";
    home.file.".config/bat".source = dotfiles + "/config/bat";
  };

}
