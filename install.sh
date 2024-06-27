#!/bin/sh

red=`echo "\033[01;31m"`
green=`echo "\033[01;32m"`
white=`echo "\033[m"`

set -ex

if grep -Fxq "NAME=Buildroot-GuppyMod" /etc/os-release; then
    printf "${green}Guppy K1 Mod is already installed. Uninstall it before continuing with a fresh install. ${white}\n"
    exit 1
fi

## bootstrap for ssl support
wget -q --no-check-certificate https://raw.githubusercontent.com/ballaswag/k1-discovery/main/bin/curl -O /tmp/curl
chmod +x /tmp/curl

asset=`/tmp/curl -s "https://api.github.com/repos/ballaswag/creality_k1_klipper_mod/releases/latest" | jq -r .assets[0].browser_download_url`

workspace=/usr/data/guppy-k1-mod

rm -rf $workspace
mkdir -p $workspace
cd $workspace

printf "${green}Downloading Guppy K1 Mod, please wait... ${white}\n"
/tmp/curl -s -L $asset -o ./k1-guppymod.tgz
printf "${green}Download completed ${white}\n"
printf "${green}Installing Guppy K1 Mod. This will take a few mintues. Please wait... ${white}\n"
tar xf ./k1-guppymod.tgz
./k1mod_init.sh

if [ $? -ne 0 ]; then
    printf "${red}Install failed ${white}\n"
else
    printf "${green}Install completed. The mod will take effect once you power cycle your printer. ${white}\n"    
fi
