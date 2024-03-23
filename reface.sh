#!/bin/bash
#need to get all functions to respect the verbose flag

default_nmap_xml="nmap_scan.xml"
default_nmap_txt="nmap_report.txt"

#need to return an ip and mac
decide_target(){
	
	
	target_file=
	if  [ $# -ne 0 ]; 
	then
		target_file=$1
		choice_type="chosen"
	else
		target_file=$default_nmap_txt
		choice_type="default"
	fi

	cat -n $target_file

	if [ $? -eq 0 ]; then
		echo choose the target
	
		read line_num		

		
		if ! [[ "$line_num" =~ ^[0-9]+$ ]]
		then 
			echo no numeric input exiting
			exit 1
		fi

		target=$(cat -n $target_file | grep "^ *$line_num")
	
		if [ $? -ne 0 ]
		then 
			echo can\'t find the target 
			exit 1
		fi
		if [ "verbose_flag" == "1" ]
		then	
			echo chose $target
		fi
	else
		echo $choice_type file wasn\'t found enter a file name or a [q]uit
		read filename
		if [ "$filename" == "q" -o "$filename" == "quit" ]; then
			echo bye
			exit 0
		else
			decide_target $filename 
		fi
	fi
	
	host_to_become="$(echo $target | cut -f2 -d' ')	$(echo $target | cut -f3 -d' ')"
	#export host_to_become=$host_to_become
	target_ip=$(echo $host_to_become | cut -f1 -d' ' )
	target_mac=$(echo $host_to_become | cut -f2 -d' ' )
}

decide_network(){
	./bin/mynets.sh > networks.txt
	./bin/mydevs.sh > devices.txt

	network_to_scan=



	if [ -z "$(cat -n networks.txt)" ]
	then
		echo no networks found exiting
		exit 1
	fi

	if [[ $(cat -n networks.txt | wc -l) > 1 ]]
	then
		paste networks.txt devices.txt | nl
		read -p "network to scan : " network_num_to_scan
		
		if ! [[ "$network_num_to_scan" =~ ^[0-9]+$ ]]
		then
			echo no numeric input exiting
			exit 1
		fi
		network_to_scan=$(cat -n networks.txt | grep -o "^ *$network_num_to_scan.*$" | awk '{print $2}')
	else
		network_to_scan=$(cat networks.txt)
	fi
	if [ $verbose_flag -eq 1 ]
	then
		echo chose $network_to_scan
	fi
	network_to_scan=$network_to_scan	
}

scan(){
	
	redirect_dest='/dev/null'
	
	decide_network

	if [ $verbose_flag -eq 1 ]
	then
		echo scanning $network_to_scan storing xml file to $default_nmap_xml
		redirect_dest=1
	fi
	
	nmap_command="sudo nmap $1 -Pn -oX $default_nmap_xml $network_to_scan"
	
	#debug
	echo "$nmap_command >&$redirect_dest"

	$nmap_command >&$redirect_dest
	if [ $? -ne 0 ]
	then
		echo error scanning
		exit 1
	fi
}

decode_xml(){

	file_to_decode=

	if [ $# -ne 0 ]
	then
		file_to_decode="$1"
	else
		file_to_decode=$default_nmap_xml
	fi
	if [ $verbose_flag -eq 1 ]
	then
		echo decoding $file_to_decode file storing to $default_nmap_txt
	fi
	python3 bin/decoder.py | grep -v "Routerboard.com" > $default_nmap_txt
}

delete_temps(){
	rm $default_nmap_xml $default_nmap_txt networks.txt devices.txt
}

handle_flags(){

	help_str="-v verbose\n-r delete all tempfile created after execution"


	if [ $# -ne 0 -a "$1" == "-h" ]
	then
		echo -e $help_str
		exit 0
	fi



	for arg in "$@"
	do
		if [ "$arg" == "-v" ]
		then
			verbose_flag=1
		elif [ "$arg" == "-r" ]
		then
			delete_flag=1
		else
			echo -e $help_str
			exit 0
		fi
	
	done

}

decide_device(){
	./bin/mydevs.sh -a > alldevices.txt
	cat -n alldevices.txt
	echo what device to effect?
	read device_line_num
	if ! [[ "$device_line_num" =~ ^[0-9]+$ ]]
	then
		echo no numeric input exiting
		exit 1
	fi
	
	dev=$(cat -n alldevices.txt | grep "^ *$device_line_num" | awk '{print $2}')

	if [ $verbose_flag -eq 1 ]
	then
		echo chose $dev
	fi

	dev=$dev
}

verbose_flag=0
delete_flag=0
handle_flags $@


if [ $verbose_flag -eq 1 ]
then
	echo verbose enabled
fi

echo scan?[y/N]
read scan

if [ ! $scan ]; then
	if [ $verbose_flag -eq 1 ]
	then
		echo -e "no input... going without a scan\n\n"
	fi
	decide_target
	decide_device
	./bin/changeme.sh $target_ip $target_mac $dev

elif [ "$scan" == "n" -o "$scan" == "N" ]; then
	
	if [ $verbose_flag -eq 1 ] 
	then
		echo -e "going without a scan\n\n"
	fi
	decide_target
	decide_device
	./bin/changeme.sh $host_to_become $dev
else
	echo enter any args you with to pass to nmap
	read nmap_args

	scan $nmap_args
	decode_xml	
	decide_target
	decide_device
	./bin/changeme.sh $host_to_become $dev
fi

if [ $verbose_flag -eq 1 -a "$2" == "-r" ]
then
	delete_temps
elif [ $delete_flag -eq 1 -a "$2" == "-r" ]
then
	delete_temps
fi

