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
my @keybinds;
my @packages = ("cmus", "cowsay", "dos2unix", "fortune-mod", "irssi", "mpv", "neofetch", "perl", "python-pywal", "rsync", "screen", "texmaker", "vnstat", "youtube-dl");
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

# Update system, install packages
if ($base || $full){
	# Start by ensuring everything is up to date
	system "sudo pacman -Syu --noconfirm --verbose";
	
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
}

# Run rsync
if ($addr){
	system "mkdir -p ~/Documents/rsync/ && rsync -avzhe ssh '$addr':~/rsync/* ~/Documents/rsync";
#	Setup symlinks pointing towards the rsync folder
#	ln --symbolic -T ~/Documents/rsync/Pictures/ ~/Pictures
#	ln --symbolic -T ~/Documents/rsync/Articles/ ~/Documents/Articles
}

if ($restart eq "required") {
	system "shutdown -r";
}