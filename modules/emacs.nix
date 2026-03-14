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
          epkgs.mu4e
          epkgs.pdf-tools
          treesit
        ])
      );
    };

    xdg.enable = true;
    home = {
      packages = with pkgs; [
        # mu4e+mbsync
        mu
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
        nodePackages.prettier
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.typescript
        nodePackages.typescript-language-server
        shellcheck

        babashka
        clojure
        clojure-lsp
      ];
      # put custom .doom.d/bin/ on path
      sessionPath = lib.mkAfter [
        "${config.home.homeDirectory}/.emacs.d/bin"
      ];
      sessionVariables = {
        EDITOR = "emacsclient";
        VISUAL = "emacsclient";
      };
    };
    xdg.configFile = {
      # TODO treesitter after removing doom
      # tree-sitter subdirectory of the directory specified by user-emacs-directory
      # "doom-local/cache/tree-sitter".source = "${treesit}/lib";
      # git clone git@github.com:torgeir/.emacs.d.git ~/.doom.d
      ".emacs.d".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.doom.d";
    };
  };
}
