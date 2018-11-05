" put these lines in ~/.vimrc
syntax on
set relativenumber


set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" chiller hax to repare delete key
set backspace=indent,eol,start

" utf8 support
if has("multi_byte")
  set encoding=utf-8
  setglobal fileencoding=utf-8
else
  echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte"
endif
