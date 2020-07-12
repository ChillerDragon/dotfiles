# version 0003
alias start='xdg-open'
alias mmh='zzh --mosh'
alias grep='grep --color=auto'
for((i=1;i<9;i++))
do
    eval "alias zzh$i='zzh $i'"
    eval "alias mmh$i='zzh --mosh $i'"
done
