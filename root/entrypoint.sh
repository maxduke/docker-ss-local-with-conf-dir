#!/bin/sh
set -e

echo 'Start'

for file in /ss-local/conf/*
do
	if test -f $file
	then
		echo $file
		ss-local -c $file -f /var/run/$file.pid
	fi
done

echo 'All done'

exec tail -f /dev/null

echo 'Existing'
