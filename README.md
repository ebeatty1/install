# Install
Automates the normal initial setup of personal Linux machines. Designed to work with Manjaro Linux, but likely works on other 
Arch-based distributions (or, more generally, any machine that has pacman installed).

## Dependencies
`pacman`

## Instructions
```sh
wget https://raw.githubusercontent.com/ebeatty1/install/master/install.pl
perl ./install.pl [options]
```

## Considerations
For users other than myself:
1. @packages and @aurpackages should be edited to include packages that fit the needs of an individual user
1. The rsync section should be edited, as symlink creation is based on the heirarchy of my own rsync directory

For use on systems that aren't fresh installs:
1. --rsync and --full remove certain directories, as well as anything contained within them, before creating symlinks; make sure 
this behavior is understood before running, or config files and pictures might be lost
