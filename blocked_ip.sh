#!/bin/bash

{
	echo "create geoblock hash:net family inet"
	for cc in RU AR; do
		location list-networks-by-cc --family=ipv4 $cc | while read ip; do
			echo "add geoblock $ip"
		done
	done
} > /home/kamil/Linux

ipset restore < /home/kamil/Linux
ipset list geoblock > lista
head -10 lista
