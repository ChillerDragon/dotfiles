" version 0006
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

" tmux colors
" https://github.com/tmux/tmux/issues/699#issuecomment-269572025
" thanks to gapplef ( Julian Chen )
set background=dark
set t_Co=256

" Allow saving of files as sudo when I forgot to start vim using sudo.
" https://stackoverflow.com/a/7078429
" thanks to Nathan Long
cmap w!! w !sudo tee > /dev/null %

" build hotkeys
" https://stackoverflow.com/a/18296266
" thanks to FDinoff
autocmd filetype python nnoremap <F4> :w <bar> exec '!python '.shellescape('%')<CR>
autocmd filetype sh noremap <F4> :w <bar> exec '!bash '.shellescape('%')<CR>
autocmd filetype c nnoremap <F4> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd filetype asm nnoremap <F4> :w <bar> exec '!mkdir -p /tmp/vim_asm_c/ && nasm -f elf64 '.shellescape('%').' -o '.shellescape('/tmp/vim_asm_c/%:r.o')' && ld -s -o '.shellescape('/tmp/vim_asm_c/%:r')' '.shellescape('/tmp/vim_asm_c/%:r.o')' && echo "Build successful. Press <F5> to run."'<CR>
autocmd filetype asm nnoremap <F5> :w <bar> exec '!if [ -f '.shellescape('/tmp/vim_asm_c/%:r')' ];then '.shellescape('/tmp/vim_asm_c/%:r')'; else echo "Error: press <F4> to compile first";fi'<CR>
