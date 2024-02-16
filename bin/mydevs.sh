#!/bin/bash

no_carrier_filter=
if [ $# -ne 0 -a "$1" == "-a" ]
then
	no_carrier_filter='cat'
else
	no_carrier_filter='grep -v NO-CARRIER'
fi

ip addr | grep -E -o "[0-9]+: [[:alnum:]]+.*UP.*" | $no_carrier_filter | cut -f2 -d' ' | tr -d ':'

