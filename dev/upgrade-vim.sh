#!/bin/bash
# stop on any error to make sure nothing gets corrupted
set -e

# TODO:
# check git status and if it is clean git pull automatically
# if status is dirty cancle
# to make sure our versions are up to date

aRCVersions=();aRCSha1s=()

REPO_FILE=vimrc
RC_FILE=~/.vimrc
VERSION_FILE=vim_versions.txt
LOCAL_BAK="${RC_FILE}.bak"
TMP_BAK="/tmp/${REPO_FILE}_$(date +%s).bak"

echo "!!! WARNING !!!"
echo "Only run this script if you know what you are doing!"
echo "Make sure to have a up to date $VERSION_FILE"
echo "Always run git pull before executing this!"
echo ""
echo "This script looks at your $RC_FILE and updates the $REPO_FILE in this repo"
echo ""
echo "usage: update your $RC_FILE file BUT NOT THE VERSION and then run the script"
echo "the script updates the version and computes a sha1 and stores it in the repo"
read -p "Run the script? [y/N]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "stopping..."
    exit 1
fi

if [ -f "$VERSION_FILE" ]
then
    VERSION_FILE="$VERSION_FILE"
elif [ -f "dev/$VERSION_FILE" ]
then
    VERSION_FILE="dev/$VERSION_FILE"
else
    echo "Error: $VERSION_FILE not found"
    exit
fi

if [ -f "$REPO_FILE" ]
then
    REPO_FILE="$REPO_FILE"
elif [ -f "../$REPO_FILE" ]
then
    REPO_FILE="../$REPO_FILE"
else
    echo "Error: $REPO_FILE not found"
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
    aRCVersions+=("$version");aRCSha1s+=("$sha1")
    # echo "loading sha1=$sha1 version=$version ..."
done < "$VERSION_FILE"

hash_found=$(sha1sum "$RC_FILE" | cut -d " " -f1)
hash_latest="${aRCSha1s[${#aRCSha1s[@]}-1]}"
version_found=$(head -n 1 "$RC_FILE" | cut -d " " -f3)
version_latest="${aRCVersions[${#aRCVersions[@]}-1]}"
echo "found $REPO_FILE version=$version_found latest=$version_latest"
echo "found $REPO_FILE sha1=$hash_found latest=$hash_latest"
if [ "$version_found" != "$version_latest" ]
then
    echo "Error: version is not latest."
    exit
elif [ "$hash_found" == "$hash_latest" ]
then
    echo "Error: version is already up to date"
    exit
fi

# convert to decimal using expr
# because leading zeros are octal in bash
# so versions higher than 0007 would not be supported
version_updated=$(expr $version_latest + 1)
if [ $? -ne 0 ]; then echo "Error: failed to update version.";exit 1; fi
if [ "$version_latest" -ge "$version_updated" ]
then
    echo "Error: updated='$version_updated' is not bigger than latest='$version_latest'"
    exit 1
fi
version_updated=$(printf "%04d\\n" "$version_updated")
if [ $? -ne 0 ]; then echo "Error: failed to parse version.";exit 1; fi
echo "updating '$version_latest' -> '$version_updated' ..."

cp "$RC_FILE" "$REPO_FILE"
cp "$RC_FILE" $LOCAL_BAK
cp "$RC_FILE" "$TMP_BAK"
echo "Backupped $REPO_FILE to:"
echo "  $LOCAL_BAK"
echo "  $TMP_BAK"

rc_body=$(sed -n '2,$p' "$REPO_FILE")
rc_header="\" version $version_updated"

echo "$rc_header" > "$REPO_FILE"
echo "$rc_body" >> "$REPO_FILE"

hash_updated=$(sha1sum "$REPO_FILE" | cut -d " " -f1)
echo "updating '$hash_latest' -> '$hash_updated' ..."

echo "$hash_updated $version_updated" >> "$VERSION_FILE"

cp "$REPO_FILE" "$RC_FILE" # overwrite local rc file with new version to not get a custom oudated version

echo ""
echo "done."
echo ""

read -p "View git diff? [y/N]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "aborting..."
    echo "make sure to commit manually:"
    echo "cd .. && git diff"
    echo "git add . && git commit"
    exit 1
fi

cd ..
git diff
read -p "Commit and release? [y/N]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "aborting... (warning uncommited changes)"
    exit 1
fi

git add .
git log
git commit
git push
git status

# show result in browser if crools is installed
# https://github.com/ChillerDragon/crools/blob/master/vb
if [ -x "$(command -v vb)" ]; then
    vb
fi

