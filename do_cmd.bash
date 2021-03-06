#!/bin/bash

# Bill Sacks
# 4-16-11

# This function echoes the command given by $1 (cmd), then executes it.
# However, if $2 (dryrun) is non-zero, then it only does the echo, not the execution.
# Usage: do_cmd cmd dryrun
# Returns 0 on success, non-zero on failure; if there is an error, the error string is echoed.
function do_cmd {
    if [[ $# -ne 2 ]]; then
	echo "ERROR in do_cmd: wrong number of arguments: expected 2, received $#"
	return 1
    fi

    local cmd=$1
    local dryrun=$2

    echo $cmd
    if [ $dryrun -eq 0 ]; then
	# We use 'eval $cmd' rather than just '$cmd', because the
	# latter doesn't work right if the command contains any quoted
	# strings (e.g., svn ci -m "this is my message")
	eval $cmd
	if [ $? -ne 0 ]; then
	    echo "ERROR in do_cmd: error executing command"
	    return 2
	fi
    fi

    return 0
}