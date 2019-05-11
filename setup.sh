#!/bin/bash
function update_vim() {
    echo "[vim] updating..."
    cp vimrc ~/.vimrc
}

function update_bashprofile() {
    echo "[bash_profile] has to be done manually."
}

echo "Starting chiller configs setup script"
echo "This script replaces config files without backups."
echo "Data might be lost!"
echo "Do you really want to execute it? [y/N]"
read -n 1 -p "" inp
echo ""
if [ "$inp" == "Y" ]; then
    test
elif [ "$inp" == "y" ]; then
    test
else
    echo "Stopped script."
    exit
fi

update_vim
update_bashprofile

