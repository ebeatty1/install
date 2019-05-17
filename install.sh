#!/usr/bin/bash

# Un-comment in the final version
# pacman -Syu

declare -a packages

# Un-comment the full array and comment the testing array in the final version
# packages=(cmus irssi mpv neofetch perl rsync scite screen texmaker vnstat youtube-dl)
packages=(irssi)

# Un-comment the full command in the final version
# sudo pacman -S ${packages[*]} --noconfirm --needed --verbose 1> ./pac.log 2> ./pac.err
sudo pacman -S ${packages[*]} --noconfirm --needed --verbose

# Again, un-comment out the full command in the final version
# This section is for packages in the arch user repo
# cd ~/Downloads
# git clone https://aur.archlinux.org/scite.git
# cd ./scite
# makepkg -si
# cd ../
# rm -R ./scite			# Should I do this? A binary gets placed in /usr/bin
# cd ~

# If the flag -r is provided with an argument in the form of user@address of the backup
# server (i.e. evan@192.168.1.2), run rsync and setup all appropriate symlinks
# Alternatively, if the flag -u is provided, run some basic updates
while getopts ":r:u" opt; do
        case $opt in
                r)
			mkdir -p ~/Documents/rsync/
			rsync -avz "$OPTARG":~/Pictures/ ~/Documents/rsync/Pictures/ >&2
			rsync -avz "$OPTARG":~/Documents/Articles/ ~/Documents/rsync/Articles >&2
                        ln --symbolic -T ~/Documents/rsync/Pictures/ ~/Pictures
			ln --symbolic -T ~/Documents/rsync/Articles/ ~/Documents/Articles
			;;
		u)
			echo "Updating" # placeholder
					# this flag might not be necessary when I finish this up
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
