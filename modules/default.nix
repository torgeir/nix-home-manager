{ pkgs, lib, isLinux ? false, ... }:

{
  imports = [
    ./alacritty.nix
    ./emacs.nix
    ./nvim.nix
    ./git.nix
    ./firefox.nix
    ./zoxide.nix
    ./shell-tooling.nix
    ./tmux.nix
  ] ++ lib.optionals (isLinux) [ ./sway.nix ];

}
