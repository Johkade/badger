#!/bin/bash

#check if node is synced

syncing=$(docker exec eth_node geth --exec 'eth.syncing' attach)
if [ "$syncing" == "false" ]
then
	echo "syncing is up to date, scanning process begins."

	get_latest_block="docker exec eth_node geth --exec 'eth.getBlock(\"latest\").number' attach"

	block=$(eval $get_latest_block)
	
	#scanning for new blocks
	while true
	do
		new_block=$(eval $get_latest_block)
		if [ $new_block -gt $block ]
		then
			echo Honeypot_Radar:::: :::: latest block is: $new_block
			block=$new_block
			echo Honeypot_Radar:::: :::: scanning block : $new_block for contract creations
			get_tx_count="docker exec eth_node geth --exec 'eth.getBlockTransactionCount($block)' attach"
			tx_count=$(eval $get_tx_count)
			echo Honeypot_Radar:::: ::::  $tx_count TXs in block $block

			#get TXs of current block
			get_txs="docker exec eth_node geth --exec 'eth.getBlock($block).transactions' attach"
			txs=$(eval $get_txs)
			#transfrom json to array for iteration
			txs_="${txs:1}"
			txs__="${txs_::-1}"
			
			IFS=', ' read -r -a tx_array <<< "$txs__"
			
			#iterate over all TXs of current block and check 'to' for NULL (=contract creation)
			contracts_found=0
			for tx_hash in "${tx_array[@]}"
			do
				#get tx hash
				#get 'to'-field and check if null
				get_tx_to="docker exec eth_node geth --exec 'eth.getTransaction($tx_hash).to' attach"
				tx_to=$(eval $get_tx_to)
				if [ "$tx_to" = "null" ]
				then
					#get contract's address from transactionReceipt, --> and the bytecode
					contracts_found=$contracts_found+1
					get_contract_addr="docker exec eth_node geth --exec 'eth.getTransactionReceipt($tx_hash).contractAddress' attach"
					contract_addr=$(eval $get_contract_addr)
					echo Honeypot_Radar:::: :::: Alert: newly created Contract found at address: $contract_addr 
					get_bytecode="docker exec eth_node geth --exec 'eth.getCode($contract_addr)' attach"
					bytecode=$(eval $get_bytecode)
					#write new contract to contracts.csv
					printf "$contract_addr, $tx_hash, $bytecode" >> ./contracts.csv
				fi
			done
			echo Honeypot_Radar:::: :::: "block scanning for block $block finished. Found $contracts_found newly created contracts "
		fi
		sleep 3
	done

else
	echo "node is not fully synced, you'll have to wait a little longer..."
fi

