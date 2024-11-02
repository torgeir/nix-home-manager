{ lib, ... }:

{
  imports = [ ./emacs.nix ];

  options.programs.doomemacs.enable =
    lib.mkEnableOption "Enable doom emacs configuration.";
}
