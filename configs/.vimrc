" THE ULTIMATE VIMRC ========================================================="
" https://github.com/amix/vimrc

let g:snipMate = { 'snippet_version' : 1 }

" DEFAULTS:START============================================================= "

set runtimepath+=~/.vim_runtime

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim
source ~/.vim_runtime/vimrcs/extended.vim

try
source ~/.vim_runtime/my_configs.vim
catch
endtry

" DEFAULTS:END=============================================================== "

" NERDTREE - open ONLY when NO FILE is specified !! :D
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let NERDTreeShowHidden=1 " SHOE HIDDEN FILES

" Folder for plugins; 
" although 'plug.vim' plugin manager, can just pull directly from Github URLs

call plug#begin('~/.vim/plugged') " PLUG:START =========================== "

" Make sure you use single quotes !!

Plug 'flazz/vim-colorschemes'
" colorscheme molokai_dark
" colorscheme SlateDark
colorscheme PerfectDark

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Fugitive is the premier Vim plugin for Git.
Plug 'https://github.com/tpope/vim-fugitive.git'

" Object select, of different types"
Plug 'michaeljsmith/vim-indent-object'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin' |
            \ Plug 'ryanoasis/vim-devicons'

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Initialize plugin system
call plug#end() " PLUG:END =============================================== "
