# badger
SRS Project Ethereum Honeypots

Manual for scanning new Blocks for honeypots:

Environment: Linux distribution, original environment is ubuntu 18.04
> install docker

> pull geth image from docker hub and run according to the official documentation: 
see here: https://github.com/ethereum/go-ethereum/wiki/Running-in-Docker

>wait for the node to be synched (takes anywhere from 2-5 days, depending on RAM, download and disk speed)
  > it is advised to use at least 8GB RAM and a SSD with about 300 GB of free storage
  
> pull honeybadger image from dockerhub and run it in the background:
  see here: https://github.com/christoftorres/HoneyBadger
  
> name the docker containers eth_node and honeybadger, respectively. 
  
> in order to start scanning new Blocks, pull this repository via git and run the script scan_for_honeypots.

> the script will initiate the scanning of new blocks for contracts and the honeypot-investigation of every contract that is discovered.
> honeypots that are discovered are automatically published to https://twitter.com/HoneypotRadar

> questions and help are welcome at johannes.kade@hof-university.de

All credits for the tool HoneyBadger go to Christof Ferreira Torres, Mathis Steichen and Radu State. 
See their original paperand project here:  https://github.com/christoftorres/HoneyBadger

