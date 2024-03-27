#!/bin/bash
#takes a MAC IP and interface name then changes the interface MAC and IP to provides ones
timeout=2

#current mac on interface
current_mac=$(sudo ifconfig > /tmp/ifconfig && sudo ifconfig | nl --body-numbering=a | grep -E ".*[0-9]+.*$3" | cut -f1 | xargs -I {} tail -n+{} /tmp/ifconfig | grep -E -o "([[:alnum:]]{2}:){5}[[:alnum:]]{2}")
current_mac=$(echo $current_mac | cut -f1 -d' ')
current_mac=$(echo $current_mac | tr [a-z] [A-Z])

echo current mac of $3 is $current_mac / $2

if [ $# -ne 3 ]
then
	echo usage : [ip] [mac] [interface]
	exit 1
fi

echo $3

sudo ifconfig $3 down
sleep 2


while [ $? -ne 0 ]
do
	sleep 2
	echo taking $3 down retyring
	sudo ifconfig $3 down
done


sleep 2
if [ "$current_mac" != "$2" ]
then
	sudo macchanger -m $2 $3
	while [ $? -ne 0 ]
	do
		echo error changing mac retrying
		sleep 2
		sudo macchanger -m $2 $3 > /dev/null
	done
else
	echo mac doesnt need to change
fi
sleep 2
sudo ifconfig $3 up

while [ $? -ne 0 ]
do
	echo error getting $3 up retrying
	sleep 2
	sudo ifconfig $3 up
done

sleep 2
sudo ifconfig $3 $1

while [ $? -ne 0 ]
do
	echo error setting new ip retrying
	sleep 2
	sudo ifconfig $3 $1
done
