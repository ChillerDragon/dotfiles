#!/bin/bash
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

echo "updating vimrc"
cp vimrc ~/.vimrc
