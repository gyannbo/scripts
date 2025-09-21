#!/bin/bash

# This script tests at the end of a workday if all the git repos of a machine have commited and pushed.
# It uses a file in a directory named 'data' to get all git repo to ignore (repo used to build
# softwares like ghidra, neovim and all other gits one can have but does nothing with).
                                
#  is LANG right ?             #
if [ "$(env | grep '^LANG')" = "LANG=fr_FR.UTF-8" ]    ## change to match what is not en-US
then
	export LANG=en_US
fi

#  fill ignoregits tab      #
ignoregits[0]="begin"
i=0
while [ -n "${ignoregits[$i]}" ]	## redo this with a for loop, without awk : for var in $(cat ~/scripts/data/ignoregits)
	do
		let " i += 1 "
		ignoregits[$i]=$(awk "NR==$i" /home/gbonis/scripts/data/ignoregits )
	done
                                
#  fill system gits tab   #
sysgits[0]="begin"
i=0
find ~ -name '.git' > temp
sed -i 's/\/\.git//g' temp
while [ -n "${sysgits[$i]}" ]			## redo this with a for loop, without awk : for var in $(find ~ -name '.git)
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
       if [[ "$(git status | sed -n 4p)" = "nothing to commit, working tree clean" ]] && \
           { [[ "$(git status | sed -n 2p)" = "Your branch is up to date with 'origin/master'."  ||\
            "$(git status | sed -n 2p)" = "Your branch is up to date with 'origin/main'." ]] }
		then
			echo " SUCCESS : ${sysgits[$i]} "
			let " i += 1 "
		else
			echo " FAIL : ${sysgits[$i]} "
			let " i += 1 "
		fi
	done
exit
