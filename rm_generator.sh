#! /bin/bash
########
####################################################################################################
#Script for randomization of musics in the current directory tree
#@author:	Iago Gomes
#@date:		08/03/2021
#@version:	1.0 (08/03/2021)
#@description:	
#The script fills an iPod or usb device with a list of randomized musics fetched from the directory 
#tree where it is executed. It also creates a log file with the musics fetched, for 
#the same musics shall not be repeated in the next execution.
#@observation:	ubuntu 20.04; GNU bash version 5.0.17
####################################################################################################


######################################## VARIABLES #################################################

NUM_MUSICAS=$(find . -type f -iname *.mp3  | wc -l) 

LIST_INDEXES=()

MAX_FIT_TRY=3

DEVICE=""
DEVICE_TYPE=""
DEVICE_MOUNTED=""

LOGS=""
DEVICE_SIZE=""
MUSICS=()

REGEX_VERIFY_DEVICES=""
####################################################################################################

function verify_devices()
{
	aux=$(sudo fdisk -l | grep -iE 'Disk /dev/sd|Disk model' | awk 'NR%2{printf "%s",$0;next;}1' | grep -iE 'ipod|flash disk' | awk '{gsub(/\:/,"")}1'  | awk '{print $2"."}' | awk 'NR%10{printf "%s|",$0;next;}1')
	if [ -z "$aux" ]; 
	then 
		REGEX_VERIFY_DEVICES=""
	else
		REGEX_VERIFY_DEVICES=${aux::-1}
	fi
}
 
function choose_device()
{	
	#Add the verified devices in the select list

	ARRAY_DEVICES=()	

	while IFS= read -r -d $'\n' line; do
		ARRAY_DEVICES+=( "$line" )	
	done < <( df | grep -iE "$REGEX_VERIFY_DEVICES" | awk '{print $0}' | awk '{print $1,$6}')

	echo 'choose one: '
	select dev in "${ARRAY_DEVICES[@]}" 
	do
		if [ -z "$dev" ]; 
		then
			echo 'insert device and try again';
			exit 1
		else
			DEVICE=$dev
			echo device selected: $DEVICE
			break
		fi
	done
}

function generate_musics()
{
	INDEX_ATUAL=0 
	while IFS= read -r line; do
		MUSICS+=( "$line" )
	done < <( find . -type f -iname *.mp3  -exec ls -l {}  \; | awk '{$1=$2=$3=$4=$6=$7=$8=""; print $0}' ) 

	end=1
	i=0

	while [[ $end -eq 1 ]]
	do 
		#novo index randomico
		INDEX_ATUAL=$(($RANDOM % $NUM_MUSICAS));
		echo "$INDEX_ATUAL"

		while [[ " ${LIST_INDEXES[@]} " =~ " ${INDEX_ATUAL} " ]]
		do
			INDEX_ATUAL=$(($RANDOM % $NUM_MUSICAS));	
			echo 'entrou '."$INDEX_ATUAL";
		done
		
		#verify if the size of list does not overflow the maximum size defined by the device selected by the user
		#and the user maximum size definition.
		
		#after the verifications, adds the new index into the index list
		LIST_INDEXES=( "${LIST_INDEXES[@]}" "$INDEX_ATUAL" );
		echo 'lista de indexes:' "${LIST_INDEXES[@]}";
		
		#verificar se o  tamanho do item novo estoura o tamanho maximo de armazenamento
		#$(echo "${MUSICS[100]}" | awk '{print $1}') error?
		tamanho_atual+=$((+ $tamanho_atual))

		#if [[ "$default_max_size"]]
				

		if [[ $i -eq 100 ]]; then		
			break;
		fi
		i=$(($i + 1))

	done
	echo "out of this world";
	echo "${#LIST_INDEXES[@]}";
	echo "$tamanho_atual";
}

function clear_device()
{	
	var=""
	while [[ "$var" != "y" ]] && [[ "$var" != "n" ]]; do
		echo "To continue your device will be formated. Wish to continue? [y/n]"
		read var
		
	done
		
	if [[ "$var" == "y" ]];
	then
		echo format
		if [ "${DEVICE_TYPE,,}" = "ipod" ]; then
			echo "ipod"
			#format
			#set_device_size
		elif [ "${DEVICE_TYPE,,}" = "flash disk" ]; then #USB
			echo "flash disk"
			#format
			#set_device_size	
		else
			echo "device type not compatible"
			exit 4
		fi
	else 
		echo format canceled
		exit 3
	fi
	
}

function format()
{
	echo ""	
}


function set_device_size()
{
	echo ""
}

function set_device_type()
{
	aux=`sudo echo $DEVICE | awk '{print $1}'`

	last_char_is_number="${aux: -1}"
	
	if [ "$last_char_is_number" -eq  "$last_char_is_number" ] 2>/dev/null; then 
		DEVICE_MOUNTED="$aux"
		aux="${aux::-1}"
	fi
	 
	ex="sudo fdisk -l | grep -A1 '$aux' | grep -v \"$aux\" | awk '{print \$3,\$4}' | cut -d \$'\\n' -f1"
	
	DEVICE_TYPE="$( eval $ex )"
	DEVICE_TYPE=` echo $DEVICE_TYPE | sed 's/ *$//g'`	

	echo device type: -\>"$DEVICE_TYPE"\<-
}

#function fill_device()
#{

#}

function main()
{
	verify_devices
	if [  -z "$REGEX_VERIFY_DEVICES" ]
	then
		echo 'insert device and try again';
		exit 1
	
	else 
		echo '#################SELECT DEVICE#######################';
		choose_device # set DEVICE selected
		set_device_type # set DEVICE_TYPE (iPod | Flash Disk); set DEVICE_MOUNTED /dev/sdXN
		if [ -z "$DEVICE_TYPE" ]; then 
			echo 'device type not identified';
			exit 2
		fi
		clear_device # set size and format DEVICE
	#	LOGS=create_or_read_logs()
	#	generate_musics(DEVICE_SIZE,LOGS) # reads LOGS fills: MUSICS, LOGS
	#	fill_device()
		exit 0
	fi
}

main 

#echo "${#MUSICS[@]}" 

#while [[ $i -lt ${#MUSICS[@]} ]]
#do
#	echo "$i""${MUSICS[$i]}" ;
#	i=$(($i + 1));
#done

#for line in "$MUSICS";
#do
#    if [ $line  $INDEX_ATUAL ]
#    then
#		echo "$line";
#	fi
#done
