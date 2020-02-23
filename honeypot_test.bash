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

		result=$(eval $honeypot_check)
		echo result is: $result
		time=$actual
	fi
	sleep 5
done
