{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.t-emacs;
  emacs =
    if pkgs.stdenv.isDarwin then
      (pkgs.emacs30.overrideAttrs (old: {
        # inspiration https://github.com/noctuid/dotfiles/blob/30f615d0a8aed54cb21c9a55fa9c50e5a6298e80/nix/overlays/emacs.nix
        patches = (old.patches or [ ]) ++ [
          # fix os window role so that yabai can pick up emacs
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
            sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
          })
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
            sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
          })
        ];
      })).override
        {
          # TODO still not working on macos
          withNativeCompilation = pkgs.stdenv.isLinux;
        }
    else
      pkgs.emacs30-pgtk;
  treesit = (pkgs.emacsPackagesFor emacs).treesit-grammars.with-all-grammars;
in
{

  options.programs.t-emacs.enable = lib.mkEnableOption "Enable emacs configuration.";

  config = lib.mkIf cfg.enable {

    programs.emacs = {
      enable = true;
      package = (
        (pkgs.emacsPackagesFor emacs).emacsWithPackages (epkgs: [
          epkgs.vterm
          epkgs.pdf-tools
          treesit
        ])
      );
    };

    xdg.enable = true;
    home = {
      packages = with pkgs; [
        # mbsync
        isync
        msmtp

        #webp support
        libwebp

        # emacs lsp
        nil # nix lsp https://github.com/oxalica/nil
        nixfmt

        # dot
        graphviz

        # emacs deps
        nodejs_20
        prettier
        bash-language-server
        yaml-language-server
        typescript
        typescript-language-server
        shellcheck

        babashka
        clojure
        clojure-lsp
      ];
      sessionPath = lib.mkAfter [
        "${config.home.homeDirectory}/.emacs.d/bin"
      ];
      sessionVariables =
        let
          home = config.home.homeDirectory;
        in
        {
          EDITOR = "emacsclient --socket-name ${home}/.emacs.d/server/server";
          VISUAL = "emacsclient --socket-name ${home}/.emacs.d/server/server";
        };
    };

    xdg.dataFile."tree-sitter".source = "${treesit}/lib";
  };
}
