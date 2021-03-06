#!/bin/sh

containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

file_list=()
while IFS= read -d $'\0' -r file ; do
    file_list=("${file_list[@]}" "$file")
done < <(find /usr/bin/ -iname "php*" -print0)

echo "PHP VERSION SWITCHER"
echo "--------------------"
echo "Versions Installed"

prefix="/usr/bin/php"
replaceWith=""

for item in ${file_list[*]}
	do
   		if [ "$item" != "$prefix" ]
   			then
   				echo "${item//$prefix/$replaceWith}"
   		fi
	done
echo "Enter version to switch to:"
read NUM

containsElement "/usr/bin/php$NUM" "${file_list[@]}"
returnVal=$?
if [ "$returnVal" -eq "0" ]
	then
	echo "Starting version switch:"
		for item in ${file_list[*]}
			do
		   		if [ "$item" != "$prefix" ]
		   			then
		   				sudo a2dismod "php${item//$prefix/$replaceWith}"
		   				echo "php${item//$prefix/$replaceWith}"
		   		fi
			done
		sudo a2enmod "php$NUM"
		
		sudo update-alternatives --set php /usr/bin/"php$NUM"
		sudo update-alternatives --set phar /usr/bin/"phar$NUM"
		sudo update-alternatives --set phar.phar /usr/bin/"phar.phar$NUM"
		sudo update-alternatives --set phpize /usr/bin/"phpize$NUM"
		sudo update-alternatives --set php-config /usr/bin/"php-config$NUM"
		
		echo "Restarting Apache:"
		sudo service apache2 restart
		echo "--------------------"
		echo "SWITCH DONE"
	else
		echo "PHP version not found!"
fi
