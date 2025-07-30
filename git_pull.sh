#!/bin/bash

# THIS IS THE PULL VERSION OF THE CLEAN SCRIPT
 
# This script tests at the end of a workday if all the git repos of a machine have commited and pushed.
# It uses a file in a directory named 'data' to get all git repo to ignore (repo used to build
# softwares like ghidra, neovim and all other gits one can have but does nothing with).
                                
#  is LANG right ?             #
if [ "$(env | grep '^LANG')" != "LANG=en_US" ]    ## change to match what is not en-US
then
	export LANG=en_US
fi

#  remplir ignoregits tab      #
ignoregits[0]="begin"
i=0
while [ -n "${ignoregits[$i]}" ]				## why do i need the quotes here  : https://askubuntu.com/questions/1056950/bash-empty-string-comparison-behavior
	do
		let " i += 1 "
		ignoregits[$i]=$(awk "NR==$i" /home/gbonis/scripts/data/ignoregits )
	done
                                
#  fill on system gits tab   #
sysgits[0]="begin"
i=0
find ~ -name '.git' > temp
sed -i 's/\/\.git//g' temp
while [ -n "${sysgits[$i]}" ]				## why do i need the quotes here  : https://askubuntu.com/questions/1056950/bash-empty-string-comparison-behavior
	do
		let " i += 1 "
		sysgits[$i]=$(awk "NR==$i" temp)
	done

# replace gits to ignore in sysgits by NULL #
i=1
y=1
rm temp
while [[ -n "${sysgits[$i]}" ]]
	do
		while [[ -n "${ignoregits[$y]}" ]]
		do
			if [[ "${sysgits[$i]}" = "${ignoregits[$y]}" ]]
			then
				sysgits[$i]="NULL"
				break
			fi
			let " y += 1 "
		done
		let  " i += 1 "
		y=0	
	done

# main loop
i=1
while [ true ]
	do
		if [ -z ${sysgits[$i]} ]
		then
			exit
		fi
		if [ ${sysgits[$i]} = "NULL" ]
		then
			let " i += 1 "
			continue 
		fi
		cd ${sysgits[$i]}
       if [[ "$(git pull | awk 'END{print $1}')" != "fatal:" ]]
		then
			cd - 1>/dev/null
			echo " SUCCESS : ${sysgits[$i]} "
			let " i += 1 "
		else
			echo " PROBLEM : ${sysgits[$i]} "
			cd -  1> /dev/null
			let " i += 1 "
		fi
	done
exit


## TODO
## SCRIPTS LIST ALL SYSTEM GITS 
## -err check, if data/ignoregits exist, and so on
## faire un script aussi pour pull quand j'arrive au début de la journée. Voir meme un script qui prends les deux possibilitées.

## LOG :
## if origin/main instead of origin/master, failed the tests
## some repo have a .git but fail a git status. Doesnt matter, will put them in the ignoregits.
## system can be in another language and can fail the tests
## BUG: lorsqu'on créer un fichier, il se créer dans l'environnement d'ou on lance le script, donc j'étais dans les repos git que
## je testais, il créait le fichier temp et donc quand il faisait un git status le repo n'était pas clean. Maintenant je supprime
## temp avant de faire les git status donc pas de problème je peux lançer les scripts de n'importe où.
 ## aussi pourquoi il faut tj des spaces, et des doubles [[   ## need both cases for program to be accurate
