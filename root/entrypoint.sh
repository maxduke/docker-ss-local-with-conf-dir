#!/bin/sh
set -e

echo 'Start'

for file in /ss-local/conf/*.json
do
	if test -f $file
	then
		echo $file
		nohup ss-local -c $file > /dev/null 2>&1 &
	fi
done

echo 'All done'

exec tail -f /dev/null

echo 'Existing'
