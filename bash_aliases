# version 0009
alias fd='cd "$(find . -type d | fzf)"'
alias x='ls && git status'
alias serve='echo "http://localhost:9090" && ruby -run -e httpd . -p 9090'
alias start='xdg-open'
alias mmh='zzh --mosh'
alias grep='grep --color=auto'
alias tnl='tr " " "\n"'
alias tnlx='tr " " "\n" | xsel -ib'
# lopen - line open
# fuzzy find all lines and then open the matched line in vim
alias lopen='vim $(m="$(rg -n . | fzf)";echo "$m" | cut -d":" -f1;printf +;echo "$m" | cut -d":" -f2)'
for((i=1;i<9;i++))
do
    eval "alias zzh$i='zzh $i'"
    eval "alias mmh$i='zzh --mosh $i'"
done
