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
	local formatted_date=$(date -u +"%Y-%m-%dT%H:%M:%S")
	echo "$formatted_date: $1" # output to cli
	if [ $ENABLE_LOGGING -eq 1 ]; then
		local logfile="$LOG_PATH/Intellidock.log"
		echo "$formatted_date: $1" >> $logfile 2>&1&
	fi
}

notification()
{
	if [ $ENABLE_NOTIFICATIONS -eq 1 ]; then
		osascript -e "display notification \"$1\" with title \"Intellidock\""
	fi
}

check_clamshell_state() 
{
	local state=$(ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState | head -1 | cut -f2 -d"=")
	echo $state
}

set_dock_mode()
{
	osascript -e "tell application \"System Events\" to set the autohide of the dock preferences to \"$1\""
}

usage() 
{ 
	echo ""
	echo "usage: $0 [OPTIONS]" 1>&2; 
	echo ""
	echo "OPTIONS:"
	echo "-n to enable notifications"
	echo "-l to enable logging. You can also provide a path for the log file: $0 -l ~/logfiles/"
	echo "Default logfile location is the current directory."
	exit 1; 
}

format_path()
{
	# removes possible / at the end
	str=${1%/}
	echo "$str"
}

LOG_PATH="$(pwd)"
FIRST_TIME=1
ENABLE_LOGGING=0
ENABLE_NOTIFICATIONS=0
# Previous value of the clammshell mode command. values:  Yes or No.
PREVIOUS_CLAMSHELL_STATE=$(check_clamshell_state)

# Check if Intellidock is already running
for pid in $(pgrep -f Intellidock.sh); do
    if [ $pid != $$ ]; then
        log "info: Intellidock is already running with PID $pid"
        exit 1
    else
    	log "info: Running with PID $pid"
    fi
done

# parse arguments
while getopts ":nl:" o; do
    case "${o}" in
        n)
			ENABLE_NOTIFICATIONS=1
			;;
        l)
			ENABLE_LOGGING=1
			LOG_PATH=$OPTARG

			# fix for optional path parameter taking -n option as "parameter"
			if [ "$LOG_PATH" == "-n" ]; then 
				ENABLE_NOTIFICATIONS=1
				LOG_PATH=$(pwd)
				log "info: no log path supplied. Will use current directory for log file."
			elif ! [ -d $LOG_PATH ]; then
				ENABLE_LOGGING=0
				log "error: $LOG_PATH is not a valid directory"
				usage
			fi
			;;
		:)
			# getopts doesn't support optional arguments,
			# when an optional argument is left out, it returns :,
			# we check the $OPTARG here if it matches.
			if [ $OPTARG == "l" ]; then
				ENABLE_LOGGING=1
				log "info: no log path supplied. Will use current directory for log file."
			fi
			;;
        \?)
			log "error: invalid option -$OPTARG"
			usage
			;;
    esac
done
shift $((OPTIND-1))


if [ $ENABLE_LOGGING -eq 1 ]; then
	LOG_PATH=$(format_path $LOG_PATH)

	# check for write permissions
	if ! [ -w "$LOG_PATH/" ]; then
		ENABLE_LOGGING=0
		log "error: unable to write to $LOG_PATH/"
		exit 3
	fi
	log "info: logging to $LOG_PATH/Intellidock.log"
else 
	log "info: logging: off"
fi

if [ $ENABLE_NOTIFICATIONS -eq 1 ]; then
	log "info: notifications: on"
else 
	log "info: notifications: off"
fi

# Sleep always returns true, so we can use it as a loop condition.
while sleep 3; do
	# Command for checking if Device is in "clamshell mode"
	clamshell_state=$(check_clamshell_state
)

	# First we check if clamshell state is different.
	if [ $PREVIOUS_CLAMSHELL_STATE != $clamshell_state ] || [ $FIRST_TIME -eq 1 ]; then

		# If clamshell state was different, we update the PREVIOUS_CLAMSHELL_STATE for next check
		PREVIOUS_CLAMSHELL_STATE=$clamshell_state
		FIRST_TIME=0
		
		# If Macbook is in clamshell mode, disable autohide dock
		if [ $clamshell_state == "Yes" ]; then
			log "info: Clammshellmode: yes, Autohide: off"
			set_dock_mode "false"
			notification "Device: open, Autohide: off"
		# If not in clamshell mode, enable autohide dock
		else 
			log "info: Clamshellmode: no, Autohide: on"
			set_dock_mode "true"
			notification "Device: closed, Autohide: on"
		fi
	fi
done

exit 0