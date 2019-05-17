#!/usr/bin/bash

declare -a packages

# Un-comment the full array and comment the testing array in the final version
# packages=(irssi mpv neofetch perl rsync screen texmaker vnstat youtube-dl)
packages=(irssi)

# Un-comment the full command in the final version
# sudo pacman -S ${packages[*]} --noconfirm --needed --verbose 1> ./pac.log 2> ./pac.err
sudo pacman -S ${packages[*]} --noconfirm --needed --verbose

# If the flag -i is provided with an argument in the form of user@address of the backup
# server (i.e. evan@192.168.1.2), run rsync and setup all appropriate symlinks.
while getopts ":i:" opt; do
        case $opt in
                i)
                        rsync -avz "$OPTARG":/home/user/Pictures/ ~/Documents/rsync/Pictures >&2
                        ln --symbolic -T ~./Documents/rsync/Pictures/ ~/Pictures
                        ;;
                \?)
                        echo "Invalid option: -$OPTARG" >&2
                        ;;
                :)
                        echo "Option -$OPTARG requires an argument." >&2
                        ;;
        esac
done

# I should probably just write this in perl
