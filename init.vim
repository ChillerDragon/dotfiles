" version 0003
syntax on
set relativenumber
set number

let mapleader = ","
let filename = expand("%")

" no physical line wrapping when too long
set textwidth=0 wrapmargin=0

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

" Building
"-----------------------------------------------------------------------------
" build hotkeys
" https://stackoverflow.com/a/18296266
" thanks to FDinoff
if executable('python3')
	autocmd filetype python nnoremap <F4> :w <bar> exec '!python3 '.shellescape('%')<CR>
else
	autocmd filetype python nnoremap <F4> :w <bar> exec '!python '.shellescape('%')<CR>
endif
autocmd filetype javascript nnoremap <F4> :w <bar> exec '!node '.shellescape('%')<CR>
autocmd filetype sh nnoremap <F4> :w <bar> exec '!bash '.shellescape('%')<CR>
autocmd filetype perl nnoremap <F4> :w <bar> exec '!perl '.shellescape('%')<CR>
autocmd filetype ruby nnoremap <F4> :w <bar> exec '!ruby '.shellescape('%')<CR>
autocmd filetype php nnoremap <F4> :w <bar> exec '!php '.shellescape('%')<CR>
autocmd filetype lua nnoremap <F4> :w <bar> exec '!lua '.shellescape('%')<CR>
" echo "filename '"filename"'"
if filename =~ "^src/.*\.rs$"
	autocmd filetype rust nnoremap <F4> :w <bar> exec '!cargo run'<CR>
else
	autocmd filetype rust nnoremap <F4> :w <bar> exec '!rustc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
endif
if filename == "CMakeLists.txt"
	autocmd filetype cmake nnoremap <F4> :w <bar> exec '!cmake .'<CR>
else
	if filename =~ "^/"
		" echo "absolute"
		" use absolute execution path to support compiling and especially
		" executing things like:
		" vim /tmp/foo.c
		"                                                                                               note the missing ./
		"                                                                                                      |
		"                                                                                                      V
		autocmd filetype c nnoremap <F4> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && '.shellescape('%:r')<CR>
		autocmd filetype c nnoremap <leader>rt :exec '!gcc -ggdb '.shellescape('%').' -o '.shellescape('%:r').' && 'c_dbg' '.shellescape('%:r')<CR>
	else
		" echo "relative"
		if filereadable("Makefile")
			autocmd filetype c nnoremap <F4> :w <bar> exec '!make && ./'.shellescape('%:r')<CR>
			autocmd filetype c nnoremap <leader>rt :exec '!make && 'c_gdb' ./'.shellescape('%:r')<CR>
			autocmd filetype cpp nnoremap <F4> :w <bar> exec '!make && ./'.shellescape('%:r')<CR>
			autocmd filetype cpp nnoremap <leader>rt :exec '!make && 'c_gdb' ./'.shellescape('%:r')<CR>
		else
			autocmd filetype c nnoremap <F4> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
			autocmd filetype c nnoremap <leader>rt :exec '!gcc -ggdb '.shellescape('%').' -o '.shellescape('%:r').' && 'c_dbg' ./'.shellescape('%:r')<CR>
			autocmd filetype cpp nnoremap <F4> :w <bar> exec '!g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
		endif
	endif
endif
autocmd filetype asm nnoremap <F4> :w <bar> exec '!mkdir -p /tmp/vim_asm_c/ && nasm -f elf64 '.shellescape('%').' -o '.shellescape('/tmp/vim_asm_c/%:r.o')' && ld -s -o '.shellescape('/tmp/vim_asm_c/%:r')' '.shellescape('/tmp/vim_asm_c/%:r.o')' && echo "Build successful. Press <F5> to run."'<CR>
autocmd filetype asm nnoremap <F5> :w <bar> exec '!if [ -f '.shellescape('/tmp/vim_asm_c/%:r')' ];then '.shellescape('/tmp/vim_asm_c/%:r')'; else echo "Error: press <F4> to compile first";fi'<CR>
autocmd filetype tex nnoremap <F4> :w <bar> exec '!pdflatex '.shellescape('%')<CR>

" add alternative compile key c
map c <F4>

" running tests
" type ',rt' in a shellscript to shellcheck the syntax
" <leader>rt for (run tests) inpsired by:
" httpst//8thlight.com/blog/chris-jordan/2016/06/13/running-tests-in-vim.html
if executable('figlet') " if figlet is installed add a nice banner :)
	autocmd filetype sh nnoremap <leader>rt :exec '!figlet shellcheck;shellcheck -x '.shellescape('%')<CR>
	autocmd filetype perl nnoremap <leader>rt :exec '!figlet perl-strict;perl -Mstrict -Mdiagnostics -cw '.shellescape('%')<CR>
	autocmd filetype php nnoremap <leader>rt :exec '!figlet php-lint;php -l '.shellescape('%')<CR>
	autocmd filetype lua nnoremap <leader>rt :exec '!figlet luacheck;luacheck '.shellescape('%')<CR>
	autocmd filetype python nnoremap <leader>rt :exec '!figlet pylint;pylint '.shellescape('%')<CR>
	autocmd filetype make nnoremap <leader>rt :exec '!figlet dry make;make -n'<CR>
	autocmd filetype cpp nnoremap <leader>rt :exec '!figlet clang-tidy;clang-tidy '.shellescape('%')<CR>
	autocmd filetype c nnoremap <leader>rt :exec '!figlet clang-tidy;clang-tidy '.shellescape('%')<CR>
	if executable('rubocop')
		autocmd filetype ruby nnoremap <leader>rt :exec '!figlet rubocop;rubocop '.shellescape('%')<CR>
	endif
	if executable('standard')
		autocmd filetype javascript nnoremap <leader>rt :exec '!figlet standard;standard '.shellescape('%')<CR>
	endif

	if executable('jq')
		autocmd filetype json nnoremap <leader>rt :exec '!figlet jq;echo "";cat '.shellescape('%')' \| jq'<CR>
	endif
	if filename =~ "^src/.*\.rs$"
		autocmd filetype rust nnoremap <leader>rt :exec '!figlet "cargo check";cargo check'<CR>
	endif
else
	autocmd filetype sh nnoremap <leader>rt :exec '!shellcheck -x '.shellescape('%')<CR>
	autocmd filetype perl nnoremap <leader>rt :exec '!perl -Mstrict -Mdiagnostics -cw '.shellescape('%')<CR>
	autocmd filetype php nnoremap <leader>rt :exec '!php -l '.shellescape('%')<CR>
	autocmd filetype lua nnoremap <leader>rt :exec '!luacheck '.shellescape('%')<CR>
	autocmd filetype python nnoremap <leader>rt :exec '!pylint '.shellescape('%')<CR>
	autocmd filetype make nnoremap <leader>rt :exec '!make -n'<CR>
	autocmd filetype cpp nnoremap <leader>rt :exec '!clang-tidy '.shellescape('%')<CR>
	autocmd filetype c nnoremap <leader>rt :exec '!clang-tidy '.shellescape('%')<CR>
	if executable('rubocop')
		autocmd filetype ruby nnoremap <leader>rt :exec '!rubocop '.shellescape('%')<CR>
	endif
	if executable('standard')
		autocmd filetype javascript nnoremap <leader>rt :exec '!standard '.shellescape('%')<CR>
	endif
	if executable('jq')
		autocmd filetype json nnoremap <leader>rt :exec '!cat '.shellescape('%')' \| jq'<CR>
	endif
	if filename =~ "^src/.*\.rs$"
		autocmd filetype rust nnoremap <leader>rt :exec '!cargo check'<CR>
	endif
endif

" https://vi.stackexchange.com/a/2237
" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.demo let &bin=1
  au BufReadPost *.demo if &bin | %!xxd
  au BufReadPost *.demo set ft=xxd | endif
  au BufWritePre *.demo if &bin | %!xxd -r
  au BufWritePre *.demo endif
  au BufWritePost *.demo if &bin | %!xxd
  au BufWritePost *.demo set nomod | endif
augroup END

" Plugins
"-----------------------------------------------------------------------------

" Clear highlighting on escape in normal mode
" https://stackoverflow.com/a/1037182
" thanks to @jonbho (twitter)
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

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
