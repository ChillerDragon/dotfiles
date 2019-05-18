#!/bin/bash
aVimVersions=();aVimSha1s=()
aVimVersions+=("0001");aVimSha1s+=("f851be2ceb92cf34dac541237ee5e31485cefb63")
aVimVersions+=("0002");aVimSha1s+=("5733e1b9ad5dd5c7509ed384290335207c44b812") 
aVimVersions+=("0003");aVimSha1s+=("9ee9f1dfb8423c98a252bb669fbe21ffefcd6705")
aVimVersions+=("0004");aVimSha1s+=("361060ddd9bc442ad45c07260584b56de46ebfd5")

function check_vim_version() {
    hash_found=$(sha1sum ~/.vimrc | cut -d " " -f1)
    version_found=$(head -n 1 ~/.vimrc | cut -d " " -f3)
    version_latest="${aVimVersions[-1]}"
    echo "[vim] found vimrc version=$version_found sha1=$hash_found"
    if [ "$version_found" == "$version_latest" ]
    then
        echo "[vim] already latest verson."
        return
    fi
    for v in ${!aVimVersions[@]}
    do
        if [ "$version_found" != "${aVimVersions[v]}" ]
        then
            continue
        fi
        # found version:
        if [ "$hash_found" == "${aVimSha1s[v]}" ]
        then
            echo "[vim] outdated vimrc version verified by sha1"
            echo "[vim] updating..."
            cp vimrc ~/.vimrc
        else
            echo "[vim] WARNING: not updating vim custom version found"
            echo "[vim] sha1 missmatch '$hash_found' != '${aVimSha1s[v]}'"
        fi
        return
    done
    echo "[vim] WARNING: unkown version didn't update .vimrc"
}

function update_vim() {
    if [ -f  ~/.vimrc ]
    then
        check_vim_version
        return
    fi
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

