#!/bin/bash

# Execute passed CMD arguments
echo-debug "Passing execution to: $*"
# Service mode (run as root)
if [[ "$1" == "supervisord" ]]; then
	exec gosu root supervisord -c /etc/supervisor/supervisord.conf
# Command mode (run as docker user)
else
	exec gosu 1000 "$@"
fi