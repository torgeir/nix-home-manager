{ lib, ... }:

{
  imports = [ ./emacs.nix ./nvim.nix ];

  # TODO this is not used yet, see nvim for how to do it
  options.programs.t-doomemacs.enable =
    lib.mkEnableOption "Enable doom emacs configuration.";
}
