# version 0014
alias x='ls && git status'
alias serve='echo "http://localhost:9090" && ruby -run -e httpd . -p 9090'
alias start='xdg-open'
alias mmh='zzh --mosh'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias tnl='tr " " "\n"'
alias tnlx='tr " " "\n" | xsel -ib'
alias viewcert='openssl x509 -noout -text -in'
alias fps='ps aux | fzf'
for((i=1;i<9;i++))
do
    eval "alias zzh$i='zzh $i'"
    eval "alias mmh$i='zzh --mosh $i'"
done
