{ config, lib, ... }:

let cfg = config.programs.t-zoxide;
in {

  options.programs.t-zoxide.enable =
    lib.mkEnableOption "Enable zoxide configuration.";

  config = lib.mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
