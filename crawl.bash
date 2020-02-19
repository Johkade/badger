#!/bin/bash


$timestamp = geth --exec 'eth.getBlock(3150).timestamp' attach
echo timestamp: $timestamp

$blockhash = geth --exec 'eth.getBlock(3150).hash' attach
echo blockhash: $blockhash


$txs = geth --exec 'eth.getBlock(3150).transactions' attach
$tx_num = ${#txs[@]}

echo number of transactions in block 3150: $tx_num



for i in "${txs[@]}"
do
	$txhash = $i.hash
	echo geth --exec 'eth.getTransaction("$txhash").to' attach
done
