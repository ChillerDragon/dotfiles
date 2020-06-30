#!/bin/bash

Reset='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'

is_vim_install=0

command -v sha1sum >/dev/null 2>&1 || {
    echo "Error: command sha1sum not found"
    # should be installed on linux
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        echo "brew install md5sha1sum"
    fi
    exit 1
}

function is_arch() {
    if [ -f /etc/arch-release ] && uname -r | grep -q arch
    then
        return 0
    fi
    return 1
}

function install_tool() {
    local tool
    local pckmn
    tool="$1"
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        brew install "$tool"
    else
        if is_arch
        then
            pckmn="pacman -Sy"
        else
            pckmn="apt install"
        fi
        if [ "$UID" == "0" ]
        then
            eval "$pckmn $tool"
        else
            if [ -x "$(command -v sudo)" ]
            then
                eval "sudo $pckmn $tool"
            else
                echo "[!] Error: install sudo"
                exit 1
            fi
        fi
    fi
}

function install_vim() {
    if [ -x "$(command -v vim)" ] && vim --version | grep -q '+python'
    then
        echo "[vim] vim with python support found"
    else
        echo "[vim] no vim with python support found!"
        echo "[vim] installing vim and dependencys ..."
        is_vim_install=1
        if [[ "$OSTYPE" == "darwin"* ]]
        then
            echo "[vim] Warning: darwin is not supported!"
            return
        fi
        if is_arch
        then
            install_tool              git base-devel      cmake python3             ctags cscope shellcheck
        else
            install_tool vim-nox curl git build-essential cmake python3 python3-dev ctags cscope shellcheck
        fi
    fi
}

function check_dotfile_version() {
    local dotfile
    local dotfile_path
    local versionfile
    local aVersions=()
    local aSha1s=()
    dotfile="$1"
    dotfile_repo="$2"
    dotfile_path="$3"
    versionfile=dev/${dotfile}_versions.txt

    if [ ! -f "$versionfile" ]
    then
        echo "Error: $versionfile not found"
        exit
    fi

    while read -r line; do
        if [ "${line:0:1}" == "#" ]
        then
            continue # ignore comments
        elif [ -z "$line" ]
        then
            continue # ignore empty lines
        fi
        sha1=$(echo "$line" | cut -d " " -f1 );version=$(echo "$line" | cut -d " " -f2)
        aVersions+=("$version");aSha1s+=("$sha1")
        # echo "loading sha1=$sha1 version=$version ..."
    done < "$versionfile"


    hash_found=$(sha1sum "$dotfile_path" | cut -d " " -f1)
    version_found=$(head -n 1 "$dotfile_path" | cut -d " " -f3)
    version_latest="${aVersions[${#aVersions[@]}-1]}"
    printf "[$dotfile] found %s version='%s' ... " "$dotfile" "$version_found"
    # printf "sha1=$hash_found ... "
    if [ "$version_found" == "$version_latest" ]
    then
        echo -e "already latest ${Green}OK${Reset}"
        return
    fi
    for v in "${!aVersions[@]}"
    do
        if [ "$version_found" != "${aVersions[v]}" ]
        then
            continue
        fi
        # found version:
        if [ "$hash_found" == "${aSha1s[v]}" ]
        then
            echo -e "outdated (old sha1) ${Yellow}OUTDATED${Reset}"
            echo "[$dotfile] updating..."
            cp "$dotfile_repo" "$dotfile_path"
        else
            echo -e "failed to update custom version ${Red}ERROR${Reset}"
            echo "[$dotfile] sha1 missmatch '$hash_found' != '${aSha1s[v]}'"
        fi
        return
    done
    echo -e "unkown version ${Red}ERROR${Reset}"
}

function update_rc_file() {
    local rcname
    local rcrepo
    local rcpath
    rcname="$1"
    rcrepo="$2"
    rcpath="$3"
    if [ -f  "$rcpath" ]
    then
        check_dotfile_version "$rcname" "$rcrepo" "$rcpath"
        return
    fi
    echo "[$rcname] updating..."
    cp "$rcrepo" "$rcpath" || exit 1
}

function update_tmux() {
    if [ ! -x "$(command -v tmux)" ]
    then
        install_tool tmux
    fi
    update_rc_file tmux tmux.conf "$HOME/.tmux.conf"
}

function update_bash_profile() {
    echo "[bash_profile] has to be done manually."
}

function update_teeworlds() {
    local cwd
    local twdir
    cwd="$(pwd)"
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        twdir="/Users/$USER/Library/Application Support/Teeworlds"
    else
        twdir="/home/$USER/.teeworlds"
    fi
    mkdir -p "$twdir"
    cd "$twdir" || exit 1
    if [ ! -d GitSettings/ ]
    then
        git clone git@github.com:ChillerTW/GitSettings.git
    fi
    cd GitSettings || exit 1
    git pull
    cd "$twdir" || exit 1
    if [ ! -d maps ]
    then
        git clone git@github.com:ChillerTW/GitMaps.git maps
    fi
    cd "$twdir" || exit 1
    if [ -f settings_zilly.cfg ]
    then
        echo "exec GitSettings/zilly.cfg" > settings_zilly.cfg
    fi
    cd "$cwd" || exit 1
}

function update_gitignore() {
    local global_gitignore
    global_gitignore="$(git config --global core.excludesfile)"
    if [ "$global_gitignore" == "" ]
    then
        echo "[gitignore] set global cfg to ~/.gitignore"
        git config --global core.excludesfile ~/.gitignore
    elif [ "$global_gitignore" == "$HOME/.gitignore" ] || \
        [ "$global_gitignore" == "/home/$USER/.gitignore" ] || \
        [ "$global_gitignore" == "/Users/$USER/.gitignore" ]
    then
        echo "[gitignore] global path already set"
    else
        echo "[gitignore] WARNING not overwriting custom gitignore"
    fi
    if [ ! -f ~/.gitignore ]
    then
        echo "[gitignore] creating global gitignore"
        {
            echo "" # ensure newline
            echo "# tags generated by setup.sh"
            echo "# https://github.com/ChillerDragon/dotfiles"
            echo "tags"
        } > ~/.gitignore
    else
        if ! grep -q '^tags$' ~/.gitignore
        then
            echo "[gitignore] adding 'tags' to global gitignore"
            {
                echo "" # ensure newline
                echo "# tags generated by setup.sh"
                echo "# https://github.com/ChillerDragon/dotfiles"
                echo "tags"
            } >> ~/.gitignore
        fi
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

install_vim

update_rc_file vim vimrc "$HOME/.vimrc"
update_rc_file irb irbrc "$HOME/.irbrc"
update_rc_file bash_aliases bash_aliases "$HOME/.bash_aliases"

if [[ "$OSTYPE" == "darwin"* ]]
then
    update_bash_profile
else
    update_rc_file bash bashrc "$HOME/.bashrc"
fi

update_tmux
update_teeworlds
update_gitignore

if [ "$is_vim_install" == "1" ]
then
    vim
    cwd="$(pwd)"
    cd ~/.vim/plugged/YouCompleteMe || exit 1
    python3 install.py
    cd "$cwd" || exit 1
fi

