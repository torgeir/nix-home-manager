{ config, lib, pkgs, ... }:

let cfg = config.programs.t-nvim;
in {

  options.programs.t-nvim.enable =
    lib.mkEnableOption "Enable nvim configuration.";

  config = lib.mkIf cfg.enable {

    home.file = { ".vimrc".source = ./config/vim/vimrc; };

    # https://github.com/stefanDeveloper/nixos-lenovo-config/blob/master/modules/apps/editor/vim.nix
    programs.neovim = {

      enable = true;

      withRuby = false;
      withPython3 = false;

      # alias vim=nvim
      vimAlias = true;

      extraConfig = (builtins.readFile ./config/vim/vimrc);

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/vim-plugin-names
      plugins = with pkgs.vimPlugins; [
        editorconfig-vim

        {
          plugin = catppuccin-nvim;
          type = "lua";
          config = ''
            vim.cmd.colorscheme "catppuccin-mocha"
          '';
        }

        {
          plugin = lightline-vim;
          type = "viml";
          config = ''
            source ${./config/vim/lightline.vim}
            let g:lightline = {'colorscheme': 't'}
          '';
        }

        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects

        vim-nix
        vim-surround
        vim-commentary

        {
          plugin = nerdtree;
          type = "viml";
          config = ''
            nnoremap <leader>fl :NERDTreeToggle<cr>
            nnoremap <leader>fL :NERDTreeFind<cr>
            let NERDTreeShowHidden=1
          '';
        }
        {
          plugin = fzf-vim;
          type = "viml";
          config = ''
            "let $FZF_DEFAULT_COMMAND = "fd --type f --hidden -E '.git'"
            nnoremap <leader>t  :FZF<cr>
            nnoremap <leader>sp :Rg<cr>
            nnoremap <leader>,  :Buffers<cr>
            nnoremap <leader>bb :Buffers<cr>
            nnoremap <leader>bd :bd<cr>
            nnoremap <leader>ss :BLines<cr>
            nnoremap <leader>bB :Windows<cr>
            nnoremap <leader>ff :Files<cr>
            nnoremap <leader>gg :Changes<cr>
            nnoremap <leader>hh :Helptags<cr>
            nnoremap <leader>tt :Colors<cr>
            nnoremap <leader>gl :Commits<cr>
            nnoremap <leader>oT :terminal<cr>

            nnoremap <leader>hrr :source ~/.config/nvim/init.lua<cr>
          '';
        }
      ];
    };

  };

}
