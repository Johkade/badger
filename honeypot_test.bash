#!/bin/bash

### Set initial time of file
time=`stat -c %Z ./contracts.csv`



#constantly check for newly discovered contracts
while true    
do
   actual=`stat -c %Z ./contracts.csv`

	if [[ "$actual" != "$time" ]]
	then    
		IFS=", " read -r addr tx bytecode < <(tail -n1 ./contracts.csv)
		echo Honeypot_Radar:::: :::: executing honeypot-test on contract $addr
		

		#removing  quotations in address and bytecode, and removing '0X' from bytecode
		addr_=${addr:1}
		addr__=${addr_::-1}
		
		bytecode_=${bytecode:3}
		bytecode__=${bytecode_::-1}
		honeypot_check="docker exec honeybadger python honeybadger/honeybadger.py -b -s /to_check/${addr__}.evm" 

		#writing bytecode of current contract to temporary file in /to_check
		#which is a shared directory with the honeybadger container
		touch "/to_check/${addr__}.evm"
		echo $bytecode__ > "/to_check/${addr__}.evm" 

		#check whether and which type of honeypot by checking the commands output ((not very nice code :I)
		#and write  honeypot address and technique to file honeypots.csv where changes will be monitored and published to twitter
		result=$(eval $honeypot_check)
		is_honeypot=0
		if [[ $result == *"Hidden transfer:        True"* ]];then
                	printf "$addr, Hidden transfer" >> ./honeypots.csv
		elif [[ $result == *"Balance disorder: 	 True"* ]];then
			printf "$addr, Balance Disorder" >> ./honeypots.csv
		elif [[ $result == *"Inheritance disorder:   True"* ]];then
                        printf "$addr, Inheritance disorder" >> ./honeypots.csv
		elif [[ $result == *"Uninitialised struct:   False"* ]];then
                        printf "$addr, Uninitialised struct" >> ./honeypots.csv
		elif [[ $result == *"Type overflow:          True"* ]];then
                        printf "$addr, Type overflow" >> ./honeypots.csv
		elif [[ $result == *"Skip empty string:      True"* ]];then
                        printf "$addr, Skip empty string" >> ./honeypots.csv
		elif [[ $result == *"Hidden state update:    True"* ]];then
                        printf "$addr, Hidden state update" >> ./honeypots.csv
		elif [[ $result == *"Straw man contract:     True"* ]];then
                        printf "$addr, Straw man contract" >> ./honeypots.csv
		fi


		time=$actual
	fi
	sleep 5
done
