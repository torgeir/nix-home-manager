# nix home manager modules

A collection of home manager modules shared between [torgeir/nix](https://github.com/torgeir/nix) and [torgeir/nix-darwin](https://github.com/torgeir/nix-darwin).

## how to use

To use these from a nix repo that makes use of home manager, do the following in your `./home/default.nix`

```nix
{ config, lib, pkgs, inputs, ... }:

let
  # clone it
  nix-home-manager = builtins.fetchGit {
    url = "https://github.com/torgeir/nix-home-manager";
    rev = "c1fdc3c3f10104864b60aeef06e967dc8ddcd599";
  };
in {

  # import its /modules/default.nix
  imports = [
    (nix-home-manager + "/modules")
  ];

  # enable selected modules
  programs.t-doomemacs.enable = true;
  programs.t-nvim.enable = true;
  
};
```

The above expects home manager to be set up for you user [something like this](https://github.com/torgeir/nix/blob/39f138b064670dc358a2c3b597549f0c5736afcd/flake.nix#L62)

``` nix
...

  home-manager.users.torgeir = import ./home;

...
```
