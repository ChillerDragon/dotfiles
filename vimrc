" put these lines in ~/.vimrc
syntax on
set relativenumber
set number

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" chiller hax to repare delete key
set backspace=indent,eol,start

" https://stackoverflow.com/a/7078429
" thanks to Nathan Long
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %
