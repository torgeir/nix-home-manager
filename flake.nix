{
  description = "torgeir/nix-home-manager";

  inputs = {
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };

  outputs = inputs@{ self, doomemacs }:
    {
      homeManagerModules.emacs = { config, lib, pkgs, ... }:
        import ./modules/emacs.nix {
          inputs = inputs; # doomemacs
          inherit config lib pkgs;
        };
    };
}
