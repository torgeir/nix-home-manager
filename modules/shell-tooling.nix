{ dotfiles, config, lib, pkgs, isLinux ? false, ... }:

let
  cfg = config.programs.t-shell-tooling;

  # 2025-10-14
  pkgs-unstable = import (fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/9abb87b552b7f55ac8916b6fc9e5cb486656a2f3.tar.gz";
    sha256 = "";
  }) { };
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
    home.packages = with pkgs;
      [

        # TODO remove pkgs-unstable from these when they are renamed nerd-fonts also in nix stable
        pkgs-unstable.nerd-fonts.iosevka
        pkgs-unstable.nerd-fonts.iosevka-term

        (ripgrep.override { withPCRE2 = true; })
        eza
        fd
        bat
        gawk
        htop
        btop
        watch
      ] ++ lib.optionals (isLinux) [ ncdu ];
    home.file.".config/btop".source = dotfiles + "/config/btop";
    home.file.".config/bat".source = dotfiles + "/config/bat";

    # zsh
    home.file.".zsh".source = dotfiles + "/zsh/";
    home.file.".zshrc".source = dotfiles + "/zshrc";
    home.file.".inputrc".source = dotfiles + "/inputrc";
    home.file.".zprofile".source = dotfiles + "/profile";
    home.file.".p10k.zsh".source = dotfiles + "/p10k.zsh";
  };

}
