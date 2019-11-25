" version 0016
" put these lines in ~/.vimrc

" Basics
"-----------------------------------------------------------------------------
syntax on
set relativenumber
set number

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

let mapleader = ","

" chiller hax to repare delete key
set backspace=indent,eol,start

" tmux colors
" https://github.com/tmux/tmux/issues/699#issuecomment-269572025
" thanks to gapplef ( Julian Chen )
set background=dark
set t_Co=256

" restore cursor pos
" https://stackoverflow.com/a/7894493
" thanks to MetaEd
source $VIMRUNTIME/vimrc_example.vim

" copy buffer size 1k lines and 1kb max
" https://stackoverflow.com/a/17812177
" thanks to patrickvacek
set viminfo='20,<1000,s1000

" Clear highlighting on escape in normal mode
" https://stackoverflow.com/a/1037182
" thanks to @jonbho (twitter)
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

" https://stackoverflow.com/a/28117335
" Set the filetype based on the file's extension, but only if
" 'filetype' has not already been set
au BufRead,BufNewFile *.ebash setfiletype html

" Backups, undos, and swap files
"-----------------------------------------------------------------------------
" The whole section is from docwhat's config:
" https://github.com/docwhat/dotfiles/blob/850dec8e9d4e536aa132e7fd6ba5560b1dd9c0b2/vimrc#L790
" https://stackoverflow.com/a/9528322
" Save your backup files to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/backup or .
if isdirectory($HOME . '/.vim/backup') == 0
    :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup/
set backupdir^=./.vim-backup/
set backup
" Prevent backups from overwriting each other. The naming is weird,
" since I'm using the 'backupext' variable to append the path.
" So the file '/home/docwhat/.vimrc' becomes '.vimrc%home%docwhat~'
if has('autocmd')
    augroup MyBackupGroup
        autocmd!
        autocmd BufWritePre * nested let &backupext = substitute(expand('%:p:h'), '/', '%', 'g') . '~'
    augroup END
endif

if has('macunix')
    set backupskip+=/private/tmp/*
endif

" Save your swap files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.vim/swap') == 0
    :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" viminfo stores the the state of your previous editing session
" commented out by ChillerDragon because I have no clue if I want this
" and I also want to mess with viminfo to increase copy buffer
" set viminfo+=n~/.vim/viminfo
" set viminfo^=!,h,f0,:100,/100,@100

if exists("+undofile")
    " undofile - This allows you to use undos after exiting and restarting
    " This, like swap and backup files, uses .vim-undo first, then ~/.vim/undo
    " :help undo-persistence
    " This is only present in 7.3+
    if isdirectory($HOME . '/.vim/undo') == 0
        :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
    endif
    set undodir=./.vim-undo//
    set undodir+=~/.vim/undo//
    set undofile
    set undolevels=1000         " maximum number of changes that can be undone
    set undoreload=10000        " maximum number lines to save for undo on a buffer reload
endif

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

" Missing permission
"-----------------------------------------------------------------------------
" Allow saving of files as sudo when I forgot to start vim using sudo.
" https://stackoverflow.com/a/7078429
" thanks to Nathan Long
cmap w!! w !sudo tee > /dev/null %

" Building
"-----------------------------------------------------------------------------
" build hotkeys
" https://stackoverflow.com/a/18296266
" thanks to FDinoff
autocmd filetype python nnoremap <F4> :w <bar> exec '!python '.shellescape('%')<CR>
autocmd filetype sh nnoremap <F4> :w <bar> exec '!bash '.shellescape('%')<CR>
if filereadable("Makefile")
    autocmd filetype c nnoremap <F4> :w <bar> exec '!make && ./'.shellescape('%:r')<CR>
else
    autocmd filetype c nnoremap <F4> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
endif
autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd filetype asm nnoremap <F4> :w <bar> exec '!mkdir -p /tmp/vim_asm_c/ && nasm -f elf64 '.shellescape('%').' -o '.shellescape('/tmp/vim_asm_c/%:r.o')' && ld -s -o '.shellescape('/tmp/vim_asm_c/%:r')' '.shellescape('/tmp/vim_asm_c/%:r.o')' && echo "Build successful. Press <F5> to run."'<CR>
autocmd filetype asm nnoremap <F5> :w <bar> exec '!if [ -f '.shellescape('/tmp/vim_asm_c/%:r')' ];then '.shellescape('/tmp/vim_asm_c/%:r')'; else echo "Error: press <F4> to compile first";fi'<CR>

" add alternative compile key c
map c <F4>

" running tests
" type ',rt' in a shellscript to shellcheck the syntax
" <leader>rt for (run tests) inpsired by:
" httpst//8thlight.com/blog/chris-jordan/2016/06/13/running-tests-in-vim.html
if executable('figlet') " if figlet is installed add a nice banner :)
    autocmd filetype sh nnoremap <leader>rt :exec '!figlet shellcheck;shellcheck '.shellescape('%')<CR>
else
    autocmd filetype sh nnoremap <leader>rt :exec '!shellcheck '.shellescape('%')<CR>
endif

" Plugins
"-----------------------------------------------------------------------------

" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" https://vi.stackexchange.com/a/624
call plug#begin('~/.vim/plugged')

" For MS Windows, this is probably better:
"call plug#begin('~/vimfiles/plugged')

Plug 'vim-scripts/OmniCppComplete'
Plug 'ludovicchabant/vim-gutentags'
Plug 'ycm-core/YouCompleteMe'
" TODO: automate this
" from https://github.com/ycm-core/YouCompleteMe#installation
" cd ~/.vim/plugged/YouCompleteMe
" python3 install.py --clang-completer

call plug#end()
