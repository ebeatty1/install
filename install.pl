#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $name = "install.pl";
my $help;
my $base;
my $full;

my $usage = <<"USAGE";

NAME		$name
SYNOPSIS	A short script to make initial setup and updating of Arch-based 
		distros a little easier.

USAGE		install.pl [options]
EXAMPLE (package installation): 	install.pl --base
EXAMPLE (package installation + rsync):	install.pl --full
USAGE

die "$usage\n" unless@ARGV;

my $options = <<"OPLIST";
OPTIONS:
-h (--help)	Display this list of options
-b (--base)	Install packages
-f (--full)	Install packages, run rsync, and set symlinks
OPLIST

GetOptions(
	'h|help' => \$help,
	'b|base' => \$base,
	'f|full=s' => \$full
);

if ($help){die "$usage\n$options\n";}

if ($base || $full){
	# Start by ensuring everything is up to date
	system "sudo pacman -Syu --noconfirm --verbose";

	# Un-comment the full array and comment the testing array in the final version
	# my @packages = (cmus, dos2unix, irssi, mpv, neofetch, perl, rsync, screen, texmaker, vnstat, youtube-dl);
	my @packages = ("irssi", "cmus", "neofetch");

	# Un-comment the full command in the final version
	# sudo pacman -S ${packages[*]} --noconfirm --needed --verbose 1> ./pac.log 2> ./pac.err
	system "sudo pacman -S @packages --noconfirm --needed --verbose";

	# Un-comment the full array and comment the testing array in the final version
	my @aurpackages = ("mendeley-desktop", "scite", "snapgene-viewer");
	# my @aurpackages = ("scite");

	# Again, un-comment out the full command in the final version
	# This section is for packages in the arch user repo

	while (my $aurpackage = shift@aurpackages){
		system "echo 'cd ~/Downloads && git clone https://aur.archlinux.org/$aurpackage.git && cd ./$aurpackage && makepkg -si'";
	}
}
if ($full){
	if ($full=="ip"){
		system "echo 'rsync blah blah'";
	}
	else{
		system "echo 'Please format servers addresses to match the following: user@192.168.1.2'";
	}
}
# rm -R ./scite			# Should I do this? A binary gets placed in /usr/bin
# cd ~

# If the flag -r is provided with an argument in the form of user@address of the backup
# server (i.e. evan@192.168.1.2), run rsync and setup all appropriate symlinks
# Alternatively, if the flag -u is provided, run some basic updates
# while getopts ":r:u" opt; do
#        case $opt in
#		r)
#			mkdir -p ~/Documents/rsync/
#			rsync -avz "$OPTARG":~/Pictures/ ~/Documents/rsync/Pictures/ >&2
#			rsync -avz "$OPTARG":~/Documents/Articles/ ~/Documents/rsync/Articles >&2
#                       ln --symbolic -T ~/Documents/rsync/Pictures/ ~/Pictures
#			ln --symbolic -T ~/Documents/rsync/Articles/ ~/Documents/Articles
#			;;
#		u)
#			echo "Updating" # placeholder
#					# this flag might not be necessary when I finish this up
#			;;
#                \?)
#                        echo "Invalid option: -$OPTARG" >&2
#                        ;;
#                :)
#                        echo "Option -$OPTARG requires an argument." >&2
#                        ;;
#        esac
# done

# I guess I actually got around to writing it in perl
