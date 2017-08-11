#!/bin/bash
count="0";
target="0";

function read(){
#This program uses 2 files in addition to the script itself.
#* count.txt - To keep track of how many times it has performed the script.
#* target.txt - To check hoew many times it should run the script.
if [ ! -e "/temp/count.txt" ];then
	echo "0" > /temp/count.txt
fi
	count=$(</temp/count.txt);
	echo "Read count value, $count" >> log.txt
	target=$(</temp/target.txt);
	echo "Read target value, $target" >> log.txt
}

function runCheck(){
	if [ "$count" -lt "$target" ];then
		logger "Reboot Script active: $count of $target";
		echo "Entry written to logger." >> log.txt
		increment;
		echo "'count' value increased by 1" >> log.txt
		echo "Rebooting" >> log.txt
		sudo shutdown -r now
	else
		echo "Reboot Script Active: $count of $target, complete."
	fi
	return
}

function increment(){
	#echo $count
	let "count += 1"
	echo "$count" > /temp/count.txt
}

function main(){
	echo "Script started. ($(date +%k%M))" > log.txt
	if [ $(id -u) -eq 0 ]; then
		echo "User check passed. user is root." >> log.txt
		read
		runCheck
		return
	else
		echo "ERROR: User not Root" >> /temp/error.txt
		echo "	Current UID:$(id -u)" >> /temp/error.txt
	fi
}
main
