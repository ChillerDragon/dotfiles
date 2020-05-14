#!/bin/bash

if [ ! -f vim_versions.txt ]
then
    echo "Error: vim_versions.txt not found."
    echo "       make sure you are in the correct directory."
    exit 1
fi

echo "Create a copy from a config to the dotfiles repo"
read -rp "repo file(vimrc): " repofile
read -rp "rc path(~/.vimrc): " rcfile
read -rp "$repofile comment(\"): " comment

name="$repofile"
if [[ "$name" =~ rc$ ]]
then
    name="${repofile::-2}"
fi
if [[ "$rcfile" =~ ^~ ]]
then
    rcfile="$HOME${rcfile:1}"
fi
versionfile="${name}_versions.txt"

if [ -f "$versionfile" ]
then
    echo "Error: '$versionfile' already exists."
    exit 1
fi
if [ -f "../$repofile" ]
then
    echo "Error: '../$repofile' already exists."
    exit 1
fi
if [ ! -f "$rcfile" ]
then
    echo "Error: '$rcfile' config file not found."
    exit 1
fi

cp "$rcfile" "../$repofile"

# header (rcfile)
rc_body="$(cat ../"$repofile")"
rc_header="$comment version 0001"
echo "$rc_header" > ../"$repofile"
echo "$rc_body" >> ../"$repofile"

sha1="$(sha1sum ../"$repofile" | cut -d' ' -f1)"

# version (version file)
echo "# sha1sums of the $repofile versions" > "$versionfile"
echo "$sha1 0001" >> "$versionfile"

# edit upgrade.sh (code generation)
rcfile_escaped="$(echo "$rcfile" | sed 's/\//\\\//')"
read -rd '' selectcode << EOF
            \\"$name\\"\\)\\n                init_type $repofile $rcfile_escaped \\x27$comment\\x27\\n                break\\n                ;;\\n            \\"vim\\"\\)
EOF
cmd="sed 's/\"vim\"[)]/$selectcode/' upgrade.sh"
echo "$cmd"
eval "$cmd" > tmp_upgrade.sh
mv tmp_upgrade.sh upgrade.sh

# TODO: do this better
# update version in actual used rc file
cmd="cp $rcfile /tmp/${repofile}.bak"
echo "$cmd"
eval "$cmd"
cmd="cp ../$repofile $rcfile"
echo "$cmd"
eval "$cmd"

