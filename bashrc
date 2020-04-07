# my linux settings
# far from complete and currently just something to be appended

export VISUAL=vim
export EDITOR="$VISUAL"

# wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
# sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
# sudo apt-get update && sudo apt-get install adoptopenjdk-8-hotspot

# force java8 via adoptopenjdk-8
export JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
# force openjdk-13
export JAVA_HOME=/usr/lib/jvm/openjdk-13
export PATH="$JAVA_HOME/bin:$PATH"
