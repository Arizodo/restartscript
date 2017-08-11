 #!/bin/bash

path="/Volumes/"
drive="Macintosh HD"
switch="false"

function menu(){
	echo '-Script Deployment Menu-'
	#TODO, Make Titles more clear.
	IFS=";"
	OPTIONS="Push files to Client;Delete files from client;Quit"
		select opt in $OPTIONS; do
		if [ "$opt" = "Push files to Client" ]; then
			optionPush
		elif [ "$opt" = "Delete files from client" ]; then
			optionPull
		elif [ "$opt" = "Quit" ]; then
			exit
		else
			clear
			echo "Invalid Input"
    fi
done
}

optionPush(){
	driveCheck
	if [ "$switch" = "true" ]; then
			setPath
			configScript
			configClient
			pushFiles
	else
		driveSet
		optionPush
	fi
	exit
}

optionPull(){
	driveCheck
	if [ "$switch" = "true" ]; then
			setPath
			pullFiles
	else
		driveSet
		optionPull
	fi
	exit
}

function configScript(){
	echo "Please enter the amount of times you'd like to reboot."
	target=0
	read target
	echo "$target" > files/target.txt
}

function configClient(){
	#Sets the Device's speaker volume to zero, so you don't have to hear the 'boing' every reboot.
	osascript -e "set Volume 0"
}

function driveCheck(){
	if [ -e "/Volumes/$drive/System/Library/CoreServices/boot.efi" ];then
		switch="true";
		return;
	fi
	switch="false";
	return;
}

function driveSet(){
	clear
	if [ -z "$errMsg" ]; then
		errMsg="Error, Default Boot Drive could not be found."
	fi
	echo "$errMsg"
	echo ""
	echo "Please enter the destinaton drive from the list below."
	echo ""
	ls -1 /Volumes/
	echo ""
	read -e -p "Drive:" drive
	driveCheck
	if [ "$switch" = "true" ];then
		clear
		echo "OSX install located, pushing to '$drive'"
		echo ""
		return
	else
		errMsg="Error, Specifified could not be found or is not a bootable OSX drive."
		driveSet
	fi
	#Check and optionally set the correct drive to push the files to.
}

function setPath(){
	mkdir "/Volumes/$drive/temp" 2> /dev/null
	if [ $? -eq 1 ]; then
		rm -r "/Volumes/$drive/temp/"
		mkdir "/Volumes/$drive/temp/"
	fi
}

function pushFiles(){
	cp "files/script.sh" "/Volumes/$drive/temp/"
	cp "files/target.txt" "/Volumes/$drive/temp/"
	#cp "files/count.txt" "/Volumes/$drive/temp/"
	cp "files/com.dylan.restart.plist" "/Volumes/$drive/Library/LaunchDaemons/"
	return
}

function pullFiles(){
	rm "/Volumes/$drive/Library/LaunchDaemons/com.dylan.restart.plist"
	rm -r "/Volumes/$drive/temp"
	return
}

function main(){
	if [ "$(id -u)" != "0" ];then
		echo "Error, script must be run as root.";
		echo "This is done by prepending 'sudo' to the previous command.";
		echo "Alternatively, you can just type 'sudo !!' into the terminal."
		exit
	fi
	clear
	menu
}
main
