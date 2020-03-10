#!/bin/bash
aVimVersions=();aVimSha1s=()
vf_vim=dev/vim_versions.txt

if [ ! -f $vf_vim ]
then
    echo "Error: $vf_vim not found"
    exit
fi

command -v sha1sum >/dev/null 2>&1 || {
    echo "Error: command sha1sum not found"
    # should be installed on linux
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        echo "brew install md5sha1sum"
    fi
    exit 1
}

function install_tool() {
    local tool
    tool="$1"
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        brew install "$tool"
    else
        if [ "$UID" == "0" ]
        then
            apt install "$tool"
        else
            if [ -x "$(command -v sudo)" ]
            then
                sudo apt install "$tool"
            else
                echo "[!] Error: install sudo"
                exit 1
            fi
        fi
    fi
}

is_vim_install=0

if [ -x "$(command -v vim)" ] && vim --version | grep -q 'Linking.*python'
then
    echo "[*] vim with python support found"
else
    echo "[*] no vim with python support found!"
    echo "[*] installing vim and dependencys ..."
    is_vim_install=1
    if [ "$UID" == "0" ]
    then
        apt install vim-nox curl git build-essential cmake python3 python3-dev ctags cscope shellcheck
    else
        if [ -x "$(command -v sudo)" ]
        then
            sudo apt install vim-nox curl git build-essential cmake python3 python3-dev ctags cscope shellcheck
        else
            echo "[!] Error: install sudo"
            exit 1
        fi
    fi
fi


while read -r line; do
    if [ "${line:0:1}" == "#" ]
    then
        continue # ignore comments
    elif [ -z "$line" ]
    then
        continue # ignore empty lines
    fi
    sha1=$(echo $line | cut -d " " -f1 );version=$(echo $line | cut -d " " -f2)
    aVimVersions+=("$version");aVimSha1s+=("$sha1")
    # echo "loading sha1=$sha1 version=$version ..."
done < "$vf_vim"

function check_vim_version() {
    hash_found=$(sha1sum ~/.vimrc | cut -d " " -f1)
    version_found=$(head -n 1 ~/.vimrc | cut -d " " -f3)
    version_latest="${aVimVersions[${#aVimVersions[@]}-1]}"
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

function update_teeworlds() {
    local cwd
    cwd="$(pwd)"
    mkdir -p ~/.teeworlds
    cd ~/.teeworlds || exit 1
    if [ ! -d GitSettings/ ]
    then
        git clone git@github.com:ChillerTW/GitSettings.git
    fi
    cd GitSettings || exit 1
    git pull
    cd ~/.teeworlds || exit 1
    if [ ! -d maps ]
    then
        git clone git@github.com:ChillerTW/GitMaps.git maps
    fi
    cd ~/.teeworlds || exit 1
    if [ -f settings_zilly.cfg ]
    then
        echo "exec GitSettings/settings_zilly.cfg" > settings_zilly.cfg
    fi
    cd "$cwd" || exit 1
}

function update_tmux() {
    if [ -x "$(command -v tmux)" ]
    then
        install_tool tmux
    fi
    if [ ! -f ~/.tmux.conf ]
    then
        cp tmux.conf ~/.tmux.conf || exit 1
        echo "[tmux] installed config."
    else
        echo "[tmux] config has to be updated manually."
    fi
}

echo "Starting chiller configs setup script"
echo "This script replaces config files without backups."
echo "Data might be lost!"
echo "Do you really want to execute it? [y/N]"
read -rn 1 -p "" inp
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
update_teeworlds
update_tmux


if [ "$is_vim_install" == "1" ]
then
    vim
    cwd="$(pwd)"
    cd ~/.vim/plugged/YouCompleteMe || exit 1
    python3 install.py
    cd "$cwd" || exit 1
fi

