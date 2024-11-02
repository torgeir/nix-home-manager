{ config, lib, pkgs, ... }:

let
  cfg = config.programs.t-shell-tooling;
  dotfiles = builtins.fetchGit {
    url = "https://github.com/torgeir/dotfiles";
    rev = "4d6ffad78640bfe606c24933ba9e58bd330e7cb1";
  };
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
    home.file.".config/btop".source = dotfiles + "/config/btop";
    home.file.".config/bat".source = dotfiles + "/config/bat";
  };

}
