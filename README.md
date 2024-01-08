# wtf is this?
this is a script designed to install all of my applications and dependencies, as well as configure some system settings (not all unfortunately) to get everything up and running.

# how to use the script?
the script is designed to run after you finish installing arch linux from ISO or any removable boot medium.
it is also recommended to run the script within the sudo timeout limit to fully automate the process, though you may also run it without it (not recommended, as you will need to enter in your password a few times, defeating the purpose of an automated script, but should be fine regardless).

# prerequisites.
the only prerequisite package you need is `wget` to download the script.
```
sudo pacman -S wget
```

# run teh script.
download the latest script, make it executable, and run it (run wget as sudo to start timeout).
```
sudo wget https://github.com/SimpleBrian/install-script/raw/main/simplebrian.sh
chmod +x simplebrian.sh
./simplebrian.sh
```
do note that you cannot run the script directly with sudo, or as root, because the `makepkg` command to build and install `yay` will refuse to work in a root environment.
this is a security measure i worked around by taking advantage of the sudo timeout function to make prolific use of the sudo command, while also leaving `makepkg` in a friendly,
non-root enviroment to install `yay` with.
