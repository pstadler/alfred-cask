#!/bin/bash

if [ -f ~/.bash_profile ]; then
	source ~/.bash_profile
fi
if [ -f ~/.profile ]; then
	source ~/.profile
fi

PATH=/usr/local/bin:/usr/local/homebrew/bin:$PATH

action=$1
query=$2

function installed_casks {
	installed_casks=$(brew cask list|sed -e 's/^[ \t]*/ /')
}

case "$action" in
	home)
		brew cask home $query
	;;

	notify)
		installed_casks
		if [[ $installed_casks =~ (^|[[:space:]])$query($|[[:space:]]) ]]; then
			echo Uninstalling $query
		else
			echo Installing $query
		fi
	;;

	execute)
		sleep 2
		installed_casks
		if [[ $installed_casks =~ (^|[[:space:]])$query($|[[:space:]]) ]]; then
			brew cask uninstall $query > /dev/null
			if [ $? -eq 0 ]; then
				echo ✓ $query has been uninstalled
				exit 0
			fi

			echo ✗ failed to uninstall $query
			exit 0
		fi

		brew cask install $query > /dev/null
		if [ $? -eq 0 ]; then
			echo ✓ $query has been installed
			exit 0
		fi

		echo ✗ failed to install $query
	;;

	list)
		results=$(brew cask search "$query" | egrep -v "(^=|^No cask found for)")
		installed_casks

		out=""; count=0
		for cask in $results; do
			count=$((count+1))
			if [ $count -gt 20 ]; then break; fi

			title=$cask
			subtitle="Install cask"
			icon="icon-install.png"
			if [[ $installed_casks =~ (^|[[:space:]])$cask($|[[:space:]]) ]]; then
				title="$title [installed]" #✓
				subtitle="Uninstall cask"
				icon="icon-uninstall.png"
			fi

		    out+="<item arg=\"$cask\" uid=\"cask-$(date +%s)\" valid=\"yes\">\
		            <title>$title</title>\
		            <subtitle>$subtitle (⌘+enter to open homepage)</subtitle>\
		            <icon>$icon</icon>\
		        </item>"
		done
		echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><items>$out</items>"
	;;

esac
