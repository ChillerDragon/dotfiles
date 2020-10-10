# version 0004
alias serve='echo "http://localhost:9090" && ruby -run -e httpd . -p 9090'
alias start='xdg-open'
alias mmh='zzh --mosh'
alias grep='grep --color=auto'
for((i=1;i<9;i++))
do
    eval "alias zzh$i='zzh $i'"
    eval "alias mmh$i='zzh --mosh $i'"
done
