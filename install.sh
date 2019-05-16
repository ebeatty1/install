#!/usr/bin/bash

declare -a packages
packages=(screenfetch ponysay)

sudo pacman -S ${packages[*]} --noconfirm --needed --verbose 1> ./pac.log 2> ./pac.err
