# Add this on top of the ~/.bash_profile file
# Custom by ChillerDragon

is_interactive=false
case $- in
  *i*) is_interactive=true;;
  *) is_interactive=false;;
esac

if [ $is_interactive == true ]; then
  # echo "This shell is interactive"
  echo "== ChillerDragon haxx0r bash =="
  echo "YOUR SHELL=$SHELL"
  echo "ruby -run -e httpd . -p 8000"
  echo "python -m SimpleHTTPServer"

  echo ""
  echo ""
  git config --global user.email "ChillerDragon@gmail.com"
  git config --global user.name "ChillerDragon"
  printf "github mail: "
  git config --global user.email
  printf "github username: "
  git config --global user.name
  echo ""
  if [ -f $HOME/.ssh/id_ed25519.pub ]; then
    echo "[-] remove 2nd git acc keys"
    mv $HOME/.ssh/id_ed25519 $HOME/.ssh/2nd_acc
    mv $HOME/.ssh/id_ed25519.pub $HOME/.ssh/2nd_acc
  fi
  if [ -f $HOME/.ssh/chiller/id_rsa.pub ]; then
    echo "[+] load chiller keys"
    mv $HOME/.ssh/chiller/* $HOME/.ssh/
  fi
else
  # echo "This is a script"
  test
fi

# RBENV and setup needed for rails
export PATH="${HOME}/.rbenv/bin:${PATH}"
type -a rbenv > /dev/null && eval "$(rbenv init -)" # Load rbenv if installed
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin" # some nice relative paths

# https://unix.stackexchange.com/a/113768
if command -v tmux &> /dev/null
then
    if [ ! -n "$PS1" ]
    then
        # echo "[tmux] Error: could not start (PS1)"
        return
    # elif [[ "$TERM" =~ screen ]]
    # then
    #     echo "[tmux] Error: could not start (screen)"
    #     return
    elif [[ "$TERM" =~ tmux ]]
    then
        # echo "[tmux] Error: could not start (tmux)"
        return
    elif [ ! -z "$TMUX" ]
    then
        # echo "[tmux] Error: could not start (TMUX)"
        return
    fi
    echo "start tmux? [Y/n]"
    read -r -n 1 yn
    echo ""
    if ! [[ "$yn" =~ [nN] ]]
    then
        session="$(tmux ls | head -n1 | cut -d':' -f1)";
        if [ "$session" == "" ]
        then
            exec tmux
        else
            exec tmux a -t "$session"
        fi
    fi
fi
