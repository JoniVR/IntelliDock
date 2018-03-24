# IntelliDock
Bash script for automatically turning on/off autohiding of the Dock if in "closed display mode" on MacOS.

## Short description
This script checks every 3 seconds if the device is in "clamshell mode" also known as "closed-display mode", if it is, it will disable Dock authohide and restart the Dock. If the device is not in closed-display mode, the script will enable Dock autohide.

The reason for this is because I have a 13 inch Macbook, so when I'm not docked, I don't want the dock to take up screen real estate, but when I'm at home (working on a larger screen) and the device is docked, I'd like to disable autohide. This just automates that process.

## Installation
1. Download or clone the script to your computer
2. Open a terminal window, navigate to the location where you saved the file (`cd /<folder>/`)
3. Run `chmod u+x Intellidock.sh` to allow the user to run the script
4. Run the script in the background `nohup ./Intellidock.sh &`
5. Optionally set the scipt to run at startup (see [this link](https://stackoverflow.com/questions/6442364/running-script-upon-login-mac)).
