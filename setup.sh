#!/bin/bash

Reset='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'

is_vim_install=0

function is_arch() {
    if [ -f /etc/arch-release ] && uname -r | grep -q arch
    then
        return 0
    fi
    return 1
}

function is_apple() {
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        return 0
    fi
    return 1
}

command -v sha1sum >/dev/null 2>&1 || {
    # should be installed on linux
    if is_apple
    then
        brew install md5sha1sum
    else
        echo "Error: command sha1sum not found"
        exit 1
    fi
}


function git_save_pull() {
	local repo="$1"
	if [ "$repo" == "" ]
	then
		echo "[-] Error: called git_save_pull without repo"
		exit 1
	fi
	if [ "$(git status | tail -n1)" != "nothing to commit, working tree clean" ]
	then
		echo "[!] WARNING: git pull failed! Is your $(tput bold)$repo$(tput sgr0) working tree clean?"
		return
	fi
	echo "[*] updating $repo ..."
	git pull
}

function install_tool() {
    local tool
    local pckmn
    tool="$*"
    if is_apple
    then
        brew install "$tool"
    else
        if is_arch
        then
            pckmn="pacman -Sy --noconfirm --needed"
        else
            pckmn="apt install -y"
        fi
        if [ "$UID" == "0" ]
        then
            eval "$pckmn $tool"
        else
            if [ -x "$(command -v sudo)" ]
            then
                eval "sudo $pckmn $tool"
            else
                echo "[-] Error: install sudo"
                exit 1
            fi
        fi
    fi
}

function is_package_installed() {
	local package="$1"
	if is_arch
	then
		if pacman -Q "$package" &> /dev/null
		then
			return 0
		fi
	fi
	return 1
}

function install_packages() {
	local package
	local package_files=()
	local package_file
	if [ -x "$(command -v apt)" ] || [ -x "$(command -v pacman)" ]
	then
		package_files+=("./packages/apt_and_pacman.txt")
	fi
	[[ -x "$(command -v apt)" ]] && package_files+=("./packages/apt.txt")
	[[ -x "$(command -v pacman)" ]] && package_files+=("./packages/pacman.txt")
	[[ -x "$(command -v brew)" ]] && package_files+=("./packages/brew.txt")
	for package_file in "${package_files[@]}"
	do
		echo "[*] installing $package_file ..."
		while read -r package
		do
			[[ "$package" =~ ^[:space:]*# ]] && continue
			[[ "$package" == "" ]] && continue
			is_package_installed "$package" && continue

			install_tool "$package"
		done < "$package_file"
	done
}

function install_vim() {
	if [ -d ~/.vim/plugged/YouCompleteMe ] && [ -d ~/.vim/plugged/vim-gutentags ]
	then
		return
	fi
	is_vim_install=1
	if is_arch
	then
		install_tool \
			figlet \
			git base-devel \
			cmake python3 \
			ctags cscope shellcheck
	elif is_apple
	then
		install_tool \
			figlet \
			git \
			cmake \
			ctags cscope shellcheck
	else # debian
		install_tool ctags || install_tool universal-ctags
		install_tool \
			luarocks \
			figlet \
			curl \
			git build-essential \
			cmake python3 python3-dev \
			cscope shellcheck
		luarocks install luacheck --user
	fi
	if [ -x "$(command -v vim)" ] && vim --version | grep -q '+python'
	then
		echo "[vim] vim with python support found ... ${Green}OK${Reset}"
	else
		echo "[vim] no vim with python support found! -> installing"
		if is_apple || is_arch
		then
			install_tool vim
		else
			install_tool vim-nox
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
	if [ -d ~/.tmux/plugins/tpm ]
	then
		(
			cd ~/.tmux/plugins/tpm || { echo "Error: failed to cd into tmp!"; exit 1; }
			git_save_pull tpm
		)
	else
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	fi
	update_rc_file tmux tmux.conf "$HOME/.tmux.conf"
	update_rc_file tmux-remote tmux.remote.conf "$HOME/.tmux.remote.conf"
}

function update_bash_profile() {
    echo "[bash_profile] has to be done manually."
}

function update_teeworlds() {
	local cwd
	local twdir
	cwd="$(pwd)"
	if [ "$UID" == "0" ]
	then
		echo "[teeworlds] skpping on root user ..."
		return
	fi
	if is_apple
	then
		twdir="/Users/$USER/Library/Application Support/Teeworlds"
	else
		twdir="/home/$USER/.teeworlds"
	fi
	mkdir -p "$twdir"
	cd "$twdir" || exit 1
	if [ ! -d GitSettings/ ]
	then
		git clone "${github}ChillerTW/GitSettings"
	fi
	if [ "$USER" == "chiller" ]
	then
		if [ ! -d SettingsPriv/ ]
		then
			git clone "${github}ChillerTW/SettingsPriv"
		fi
		cd SettingsPriv || exit 1
		git_save_pull SettingsPriv
		./setup.sh || exit 1
		cd .. || exit 1
	fi
	cd GitSettings || exit 1
	git_save_pull GitSettings
	cd "$twdir" || exit 1
	if [ ! -d maps ]
	then
		git clone --recursive "${github}ChillerTW/GitMaps" maps
	else
		cd maps || exit 1
		if [ -d .git ]
		then
			git_save_pull maps
		fi
	fi
	cd "$twdir" || exit 1
	if [ ! -f settings_zilly.cfg ]
	then
		echo "exec GitSettings/zilly.cfg" > settings_zilly.cfg
	fi
	mkdir -p chillerbot
	cd chillerbot || exit 1
	if [ ! -d cbs ]
	then
		git clone "${github}chillerbot/chillerbot-scripts" cbs
	elif [ ! -d cbs/.git ] && [ "$(ls cbs)" == "" ]
	then
		rm -rf cbs
		git clone "${github}chillerbot/chillerbot-scripts" cbs
	else
		cd cbs || exit 1
		git_save_pull cbs
	fi
	cd "$cwd" || exit 1
}

function install_pictures() {
    if [ "$USER" != "chiller" ]
    then
        echo "[pictures] skipping for non 'chiller' users ..."
        return
    fi
    if [ -n "$SSH_CLIENT" ]
    then
        echo "[pictures] skipping for remote sessions ..."
        return
    fi
    if [ "$UID" == "0" ]
    then
        echo "[pictures] skpping on root user ..."
        return
    fi
    mkdir -p ~/Pictures
    if [ "$(ls -A ~/Pictures)" ]
    then
        return
    fi
    echo "[pictures] downloading ~/Pictures ..."
    rm -r ~/Pictures
    git clone "${github}ChillerData/Pictures" ~/Pictures
}

function print_gitignore() {
	echo "" # ensure newline
	echo "# tags generated by setup.sh"
	echo "# https://github.com/ChillerDragon/dotfiles"
	echo "tags"
	echo "tags.lock"
	echo "tags.temp"
	echo ".gdb_history"
	echo ".cache"
	echo ".git"
}

function update_gitconfig() {
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
	local global_gitdiff
	global_gitdiff="$(git config --global diff.wsErrorHighlight)"
	if [ "$global_gitdiff" == "" ]
	then
		echo "[gitdiff] set global diff.wsErrorHighlight to all (hilite tabs)"
		git config --global diff.wsErrorHighlight all
	elif [ "$global_gitdiff" == "all" ]
	then
		echo "[gitdiff] git diff.wsErrorHighlight all already set"
	else
		echo "[gitdiff] WARNING not overwriting custom gitdiff"
	fi
	if [ ! -f ~/.gitignore ]
	then
		echo "[gitignore] creating global gitignore"
		print_gitignore > ~/.gitignore
	else
		if ! grep -q '^tags$' ~/.gitignore
		then
			echo "[gitignore] adding 'tags' to global gitignore"
			print_gitignore >> ~/.gitignore
		fi
	fi
	local git_alias_d
	git_alias_d="$(git config --global alias.d)"
	if [ "$git_alias_d" == "" ]
	then
		echo "[gitconfig] setting up alias 'git d' ..."
		git config --global alias.d "diff --word-diff --color-words"
	elif [ "$git_alias_d" == "diff --word-diff --color-words" ]
	then
		# use this branch to update the alias in case we add new flags
		test
	else
		echo "[gitconfig] warning not overwriting custom 'git d' alias!"
	fi
	git config --global core.editor vim
	git config --global pull.rebase true
	if ! git config user.name > /dev/null
	then
		git config --global user.name "ChillerDragon"
	fi
	if ! git config user.email > /dev/null
	then
		git config --global user.email "ChillerDragon@gmail.com"
	fi
	if ! git config --global init.defaultBranch
	then
		git config --global init.defaultBranch master
	fi
	if ! grep -q 'customers' ~/.gitconfig
	then
		echo "[gitconfig] linking work config"
		{
			echo '[includeIf "gitdir:~/Desktop/customers/"]'
			printf "\\tpath = .gitconfig-work\\n"
		} >> ~/.gitconfig
	fi
	if ! grep -q 'git-zilly' ~/.gitconfig
	then
		echo "[gitconfig] linking ZillyHuhn config"
		{
			echo '[includeIf "gitdir:~/Desktop/git-zilly/"]'
			printf "\\tpath = .gitconfig-zilly\\n"
		} >> ~/.gitconfig
	fi
	if [ ! -f ~/.gitconfig-zilly ]
	then
		echo "[gitconfig] writing ZillyHuhn config"
		{
			echo "[user]"
			printf "\\temail = ZillyHuhn@gmail.com\\n"
			printf "\\tname = ZillyHuhn\\n"
		} > ~/.gitconfig-zilly
	fi
}

github='git@github.com:'
if [ ! -f ~/.ssh/id_rsa.pub ]
then
    echo -e "[ssh] ${Yellow}WARNING${Reset}: no ~/.ssh/id_rsa.pub found using https for git"
    github='https://github.com/'
fi
if [ ! -d ~/.ssh ]
then
    echo -e "[ssh_config] ${Red}ERROR${Reset}: ~/.ssh not found run ssh-keygen first"
else
    if [ ! -f ~/.ssh/work_rsa ]
    then
        echo -e "[ssh_config] ${Yellow}WARNING${Reset}: ~/.ssh/work_rsa not found"
    fi
    update_rc_file ssh_config ssh_config "$HOME/.ssh/config"
fi

function symlink() {
	local src="$1"
	local dst="$2"
	if [ ! -f "$src" ]
	then
		echo "Error: failed to symlink '$src' not found"
		exit 1
	fi
	if [ -f "$dst" ]
	then
		# TODO: replace silent skip by check if this is the expected sym link
		return
	fi
	echo "[symlink] $dst"
	ln -s "$(pwd)/$src" "$dst"
}

function setup_symlinks() {
	# could also do a `cd $SCRIPT_PATH` here
	if [ ! -d vim ]
	then
		echo "Error: folder vim not found. wrong directoy?"
		exit 1
	fi
	mkdir -p ~/.vim/syntax
	mkdir -p ~/.vim/ftdetect
	symlink "vim/syntax/ddnet-cfg.vim" ~/.vim/syntax/ddnet-cfg.vim
	symlink "vim/ftdetect/ddnet-cfg.vim" ~/.vim/ftdetect/ddnet-cfg.vim
}

if [ ! -d ~/.um ] && [ "$USER" == "chiller" ]
then
	mkdir ~/.um
	git clone git@github.com:ChillerData/um-pages/ ~/.um/pages
fi

install_vim
install_pictures

setup_symlinks

update_rc_file vim vimrc "$HOME/.vimrc"
update_rc_file irb irbrc "$HOME/.irbrc"
update_rc_file bash_aliases bash_aliases "$HOME/.bash_aliases"
update_rc_file gdbinit gdbinit "$HOME/.gdbinit"
update_rc_file sqlite sqliterc "$HOME/.sqliterc"

if is_apple
then
    update_bash_profile
fi

update_tmux
update_teeworlds
update_gitconfig

# TODO: skip already installed packages
# install_packages

if [ "$is_vim_install" == "1" ]
then
    vim -c 'PlugInstall | quit | quit' || exit 1
    cwd="$(pwd)"
    cd ~/.vim/plugged/YouCompleteMe || exit 1
    python3 install.py
    cd "$cwd" || exit 1
fi

(
	cd .. || exit 1
	[[ ! -d dotfiles-private ]] && git clone git@github.com:ChillerDragon/dotfiles-private.git
	cd dotfiles-private || exit 1
	./setup.sh
)

