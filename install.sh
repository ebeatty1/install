#!/usr/bin/bash

declare -a packages
packages=(irssi mpv neofetch rsync screen texmaker vnstat youtube-dl)

sudo pacman -S ${packages[*]} --noconfirm --needed --verbose 1> ./pac.log 2> ./pac.err
