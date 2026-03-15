{
  pkgs,
  lib,
  isLinux ? false,
  ...
}:

{
  imports = [
    ./alacritty.nix
    ./ghostty.nix
    ./nvim.nix
    ./git.nix
    ./gpg.nix
    ./firefox.nix
    ./zoxide.nix
    ./shell-tooling.nix
    ./tmux.nix
  ];

}
