{
  description = "torgeir/nix-home-manager";

  inputs = {};

  outputs = inputs@{ self }:
    {
      homeManagerModules.emacs = { config, lib, pkgs, ... }:
        import ./modules/emacs.nix {
	  inputs = inputs;
          inherit config lib pkgs;
        };
    };
}
