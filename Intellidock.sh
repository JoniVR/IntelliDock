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

log()
{
	echo "`date`: $1"
}

notification()
{
	osascript -e "display notification \"$1\" with title \"Intellidock\""
}

clamshell_state_state() 
{
	echo $(ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState | head -1 | cut -f2 -d"=")
}

set_dock_mode()
{
	osascript -e "tell application \"System Events\" to set the autohide of the dock preferences to \"$1\""
}

# Check if Intellidock is already running
for pid in `pgrep -f Intellidock.sh`; do
    if [ $pid != $$ ]; then
        log "Intellidock is already running with PID $pid"
        exit 1
    else
      	log "Running with PID $pid"
    fi
done

first_time="true"

# Previous value of the clammshell mode command. values:  Yes or No.
previous_clamshell_state=$(clamshell_state_state)

# Sleep always returns true, so we can use it as a loop condition.
while sleep 3
do

# Command for checking if Device is in "clamshell mode"
clamshell_state=$(clamshell_state_state)

# First we check if clamshell state is different.
if [ $previous_clamshell_state != $clamshell_state ] || [ $first_time == "true" ]; then

	# If clamshell state was different, we update the previous_clamshell_state for next check
	previous_clamshell_state=$clamshell_state
	first_time="false"
	
	# If Macbook is in clamshell mode, disable autohide dock
	if [ $clamshell_state == "Yes" ]; then
		log "Clammshellmode: Yes, autohide: off"
		set_dock_mode "false"
		
		if [ "$1" ==  "-n" ]; then
			notification "Device: open, Autohide: off"
		fi
	# If not in clamshell mode, enable autohide dock
	else 
		log "Clamshellmode: No, autohide: on"
		set_dock_mode "true"
		
		if [ "$1" == "-n" ]; then
			notification "Device: closed, Autohide: on"
		fi
	fi
fi
done

exit 0
