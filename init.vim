" version 0001
syntax on
set relativenumber
set number

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
if has('autocmd')
    augroup MyLastCursor
        autocmd!
        autocmd BufReadPost * nested
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif
    augroup END
endif

call plug#begin('~/.vim/plugged')

" For MS Windows, this is probably better:
"call plug#begin('~/vimfiles/plugged')

" neovim
Plug 'vim-airline/vim-airline'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'

Plug 'ciaranm/detectindent'
Plug 'vim-scripts/OmniCppComplete'
Plug 'ludovicchabant/vim-gutentags'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
"if has('patch-8.1.2269')
"    Plug 'ycm-core/YouCompleteMe'
"else
"    set encoding=utf-8
"    Plug 'ycm-core/YouCompleteMe', { 'commit':'d98f896' }
"end
" TODO: automate this
" from https://github.com/ycm-core/YouCompleteMe#installation
" cd ~/.vim/plugged/YouCompleteMe
" python3 install.py --clang-completer

call plug#end()
