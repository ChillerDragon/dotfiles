" version 0003
" put these lines in ~/.vimrc
syntax on
set relativenumber
set number

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" chiller hax to repare delete key
set backspace=indent,eol,start

" Allow saving of files as sudo when I forgot to start vim using sudo.
" https://stackoverflow.com/a/7078429
" thanks to Nathan Long
cmap w!! w !sudo tee > /dev/null %

" build hotkeys
" https://stackoverflow.com/a/18296266
" thanks to FDinoff
autocmd filetype python nnoremap <F4> :w <bar> exec '!python '.shellescape('%')<CR>
autocmd filetype c nnoremap <F4> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>

