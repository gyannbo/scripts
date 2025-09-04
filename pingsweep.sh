#!/bin/bash
########################
## a quick ping sweep ##
########################





##   faire le calcul de mask avec des bitwise operator pour arreter le programme

# bug si masque comporte un chiffre
# bug si octet plus que 255
# faire en sort que si pas de masque dans l'adresse du prompt, le prompter
## possibilité de faire $(( $var + $var2 ))
## command cut ?
## tous les trucs avec les ip sont faisable avec cut -b je pense




read -p "enter a network address to ping sweep : " address trash
if [[ -z $address ]]
then
		echo "nothing typed"
		exit
fi

## rajouter calcul de masque et sanitize user input
##if [[ -n $(echo $address | sed -r 's/([0-9\.]*)//') ]]
if [[ -n $(echo $address | sed -r 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]{2}//') ]]
then
	echo "address typed is invalid"
	exit
fi

byte1=$(echo $address | sed -r 's/([0-9]*)\.[0-9]*\.[0-9]*\.[0-9]*/\1/')
byte2=$(echo $address | sed -r 's/[0-9]*\.([0-9]*)\.[0-9]*\.[0-9]*/\1/')
byte3=$(echo $address | sed -r 's/[0-9]*\.[0-9]*\.([0-9]*)\.[0-9]*/\1/')
byte4=$(echo $address | sed -r 's/[0-9]*\.[0-9]*\.[0-9]*\.([0-9]*)/\1/')
array=([0]=$byte1 [1]=$byte2 [2]=$byte3 [3]=$byte4)
#echo ${array[*]}  Print all array members


## gestion du mask, gérer si bien /n et aussi si n < 33

mask=$(echo $address | sed -r 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\/([0-9]{2})/\1/')
if [[ $mask == * ]]
then
	echo $mask
	exit
fi

i=0
while [[ $i -ne 4 ]]
do
	if [[ $(echo ${array[$i]}) -gt 255 ]]
	then
		echo "address typed not valid"
		exit
	fi
	(( i++ ))
done

## pouvoir kill le script avec ctrl-c

trap exit SIGINT

## main loop
while [[ $byte1 -ne 255 ]]
do
	while [[ $byte2 -ne 255 ]]
	do
		while [[ $byte3 -ne 255 ]]
		do
			while [[ $byte4 -ne 255 ]]
			do
				## timeout pour arreter plus rapidement quand le ping ne passe pas
				if (timeout 0.2 ping -q4Ac 3 -W 1 $byte1.$byte2.$byte3.$byte4 &> /dev/null)
				then
					echo success $byte1.$byte2.$byte3.$byte4
				fi
				let "byte4=byte4 + 1"
			done
			let "byte4=1"
			let "byte3=byte3 + 1"
		done
		let "byte3=0"
		let "byte2=byte2 + 1"
	done
	let "byte2=0"
	let "byte1=byte1 + 1"
done

