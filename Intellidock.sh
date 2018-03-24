#!/bin/bash

# MIT License
#
# Copyright (c) 2018 Joni Van Roost
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Check if Intellidock is already running
COUNT=$(ps ax | grep -i $0 | grep -v grep | wc -l)
if [ $COUNT -gt 2 ]
then
	echo $COUNT
	echo "Intellidock is already running. Exiting."
	exit 1
fi

# Previous value of the clammshell mode command. values:  Yes or No.
previous_value=$(ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState  | head -1 | cut -f2 -d"=")

# Sleep always returns true, so we can use it as a loop condition.
while sleep 3
do

# Command for checking if Device is in "clamshell mode"
check_dock=$(ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState  | head -1 | cut -f2 -d"=")

# First we check if clamshell state is different.
if [ $previous_value != $(echo $check_dock) ]
then

	# If clamshell state was different, we update the previous_value for next check
	previous_value=$check_dock
	
	# If Macbook is in clamshell mode, disable autohide dock
	if [ $(ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState  | head -1 | cut -f2 -d"=") == "Yes" ]
	then
		echo "Clammshellmode: Yes, autohide: off."
		defaults write com.apple.Dock autohide -bool FALSE

	# If not in clamshell mode, enable autohide dock
	else 
		echo "Clamshellmode: No, autohide: on."
		defaults write com.apple.Dock autohide -bool TRUE
	fi

echo "Restart dock"
killall Dock

fi
done

exit 0
