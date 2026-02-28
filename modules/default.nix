{
  pkgs,
  lib,
  isLinux ? false,
  ...
}:

{
  imports = [
    ./alacritty.nix
    ./nvim.nix
    ./git.nix
    ./firefox.nix
    ./zoxide.nix
    ./shell-tooling.nix
    ./tmux.nix
  ];

}
