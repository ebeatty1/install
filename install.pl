#!/usr/bin/perl

use strict; use warnings; use Getopt::Long qw(GetOptions);

my $name = "install.pl";
my $help;
my $base;
my $full;
my $rsync;
my $addr;
my $de;
my $xfcekeys = "$ENV{HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml";
my $restart = "";
my $walbashrc = "required";
my $walxinitrc = "required";
my @keybinds;
my @bashrc;
my @xinitrc;
my @packages = ("cmus", "cowsay", "dos2unix", "fortune-mod", "htop", "irssi", "keepassxc", "mpv", "mupdf", "neofetch", "opusfile", "rsync", "screen", "texmaker", "vnstat", "youtube-dl");
my @aurpackages = ("fastqc", "mendeleydesktop", "scite");

my $usage = <<"USAGE";

NAME		$name
SYNOPSIS	A short script to make initial setup and updating of Arch-based 
		distros a little easier.

USAGE					install.pl [options]
EXAMPLE (help)				install.pl --help
EXAMPLE (package installation): 	install.pl --base
EXAMPLE (package installation + rsync):	install.pl --full evan\@192.168.1.2
EXAMPLE (rsync)				install.pl --rsync evan\@192.168.1.2
USAGE

my $options = <<"OPLIST";
OPTIONS:
-h (--help)	Display this list of options
-b (--base)	Install packages
-f (--full)	Install packages, run rsync and set symlinks
-r (--rsync)	Run rsync
OPLIST

my $addrformat = <<"FORMAT";

When using -f (--full) or -r (--rsync), the argument should be formatted as user\@hostip
EXAMPLE (package installation + rsync):	install.pl --full evan\@192.168.1.2
FORMAT

my $walasync = <<"WALASYNC";

# Import colorscheme from 'wal' asynchronously
(cat ~/.cache/wal/sequences &)
source ~/.cache/wal/colors-tty.sh
WALASYNC

my $walreboot = <<"WALREBOOT";

# Restore the last 'wal' colorscheme that was in use.
wal -R
WALREBOOT

die "$usage\n" unless@ARGV;

GetOptions(
	'h|help' => \$help,
	'b|base' => \$base,
	'f|full=s' => \$full,
	'r|rsync=s'=> \$rsync
);

if ($help){die "$usage\n$options\n";}

# Checks to ensure that the address, if given, is formatted properly; if not, dies
if ($full) {$addr = $full;}
if ($rsync) {
	if ($addr) {exit;}
	else {$addr = $rsync;}
}
if ($addr) {chomp $addr; die "$addrformat\n" unless $addr =~ /.+\@.+/;}

# Update system, install packages
if ($base || $full){
	# Start by ensuring everything is up to date
	system "sudo pacman -Syu --noconfirm --verbose";
	
	# Removes any and all instances of xfce4-terminal --drop-down from xfce4-keyboard-shortcuts.xml
	if ($ENV{XDG_CURRENT_DESKTOP} eq "XFCE") {
		open XFCEKEYBINDS, "<$xfcekeys";
		@keybinds = <XFCEKEYBINDS>;
		close XFCEKEYBINDS;

		open XFCEKEYBINDS, ">$xfcekeys";
		while (my $line = shift(@keybinds)) {
			if ($line =~ m/\s--drop-down/) {
				$line =~ s/\s--drop-down//;
				$restart = "required";
			}
			print XFCEKEYBINDS $line;
		}
		close XFCEKEYBINDS;
	}
	
	# Install packages from the official arch repositories
	system "sudo pacman -S @packages --noconfirm --needed --verbose";
	
	# Installs AUR packages and updates packages that already exist
	system "mkdir -p ~/AUR";
	while (my $aurpackage = shift@aurpackages) {
		if (-d "$ENV{HOME}/AUR/$aurpackage") {
			system "cd ~/AUR/$aurpackage && git pull && makepkg -scCi --noconfirm --needed";
		}
		else {
			system "cd ~/AUR/ && git clone https://aur.archlinux.org/$aurpackage.git && cd ./$aurpackage && makepkg -scCi --noconfirm --needed";
		}
	}
	
	# Installs pywal from the public repository
	if (`bash -c 'wal'` eq "") {
		system "mkdir -p ~/GitHub/";
		system "cd ~/GitHub/ && git clone https://github.com/dylanaraps/pywal && cd ./pywal && sudo pip3 install .";
	}

	# Sets wal to retain changes on reboot and logout
	if (`bash -c 'wal'` eq "") {
		print "The program wal was not found.\n";
	}
	else {
		open BASHRC, "<$ENV{HOME}/.bashrc";
		@bashrc = <BASHRC>;
		close BASHRC;
		
		while  (my $line = shift(@bashrc)) {
			if ($line =~ m/cat \~\/\.cache\/wal\/sequences \&/) {
				$walbashrc = "";
				print "It doesn't look like .bashrc needs to be edited.\n";
			}
		}
		
		if ($walbashrc eq "required") {
			open BASHRC, ">>$ENV{HOME}/.bashrc";
			print BASHRC "$walasync";
			close BASHRC;
		}
		
		open XINITRC, "<$ENV{HOME}/.xinitrc";
		@xinitrc = <XINITRC>;
		close XINITRC;
		
		while  (my $line = shift(@xinitrc)) {
			if ($line =~ m/wal \-R/) {
				$walxinitrc = "";
				print "It doesn't look like .xinitrc needs to be edited.\n";
			}
		}
		
		if ($walxinitrc eq "required") {
			open XINITRC, ">>$ENV{HOME}/.xinitrc";
			print XINITRC "$walreboot";
			close XINITRC;
		}
	}
}

# Run rsync
if ($addr){
	system "mkdir -p ~/Documents/rsync/ && rsync -avzhe ssh '$addr':~/rsync/ ~/Documents/rsync/";
	
	# Sets symlinks pointing towards the rsync folder
	system "rm -rf ~/Pictures ~/Documents/Articles ~/.config/mpv";
	system "ln -nfs -T ~/Documents/rsync/Pictures ~/Pictures";
	system "ln -nfs -T ~/Documents/rsync/Documents/Articles ~/Documents/Articles";
	system "ln -nfs -T ~/Documents/rsync/Config/mpv ~/.config/mpv";
}

if (`bash -c 'wal'` eq "") {
	print "The program wal was not found.\n";
}
elsif (not -e "$ENV{HOME}/Pictures/Backgrounds/" || not -d "$ENV{HOME}/Pictures/Backgrounds/") {
	print "A Backgrounds folder was not found at ~/Pictures/Backgrounds/.\n ";
}
else {
	system "wal -i ~/Pictures/Backgrounds/";
}

if ($restart eq "required") {
	system "shutdown -r";
}
