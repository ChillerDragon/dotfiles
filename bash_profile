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
