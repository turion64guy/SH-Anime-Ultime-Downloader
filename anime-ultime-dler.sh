#!/bin/bash
# This script will download every episode of an anime on the french website Anime-Ultime.
# Accepts two parameters : URL {optional: ouput directory}
# If no output directory specified, will download in current directory
# Usage: ./anime-ultime-dler.sh http://www.anime-ultime.net/file-0-1/2426/Mahou-Shoujo-Lyrical-Nanoha-A039s-vostfr
# Or 	 ./anime-ultime-dler.sh http://www.anime-ultime.net/file-0-1/2426/Mahou-Shoujo-Lyrical-Nanoha-A039s-vostfr /home/user/Video/Nanoha/
####turion 64 guy

if [ "$1" = "" ]; then
        echo "No link specified."
	echo "Usage: ./anime-ultime-dler.sh URL"
	echo "Example: ./anime-ultime-dler.sh http://www.anime-ultime.net/file-0-1/2426/Mahou-Shoujo-Lyrical-Nanoha-A039s-vostfr"
	exit
fi

script_ver="0.1a"
base_url="http://www.anime-ultime.net"

if [ "$2" = "" ]; then #THIS IS UNTESTED, SO IT'S DISABLED.
	dl_dir=$PWD #if no download dir specified, download in current dir
else
	dl_dir=${2%/}
	#mkdir $dl_dir > /dev/null 2>&1   #TODO:change this. []If directory does not exist, this will create it, if dir already exists, mkdir is gonna fail and do nothing
	#echo "Downloading in : \"$dl_dir\""
fi

echo "Page : $1"
videolist_page_content=$(curl --silent -L $1 | iconv -f iso8859-1 -t utf-8)
#anime_name=$(echo $videolist_page_content |  grep -oE "TITRE ORIGINAL".*"<br />" | sed 's/TITRE ORIGINAL : //' | sed 's/<br \/>//') #UGLY and slow, but its the only thing that i managed to get working. Sorry

anime_name=$(echo $videolist_page_content |  grep -oE "<h1>".*"</h1>" | sed 's/<h1>//' | sed 's/<\/h1>//' | sed 's/vostfr//') #UGLY and slow, but its the only thing that i managed to get working. Sorry
echo "Anime name : $anime_name"

#extract episodes link suffixes and then extract the IDs
anime_eps_raw=$(echo $videolist_page_content | grep -oP "Télécharger<\/a> - <a href=\"".*?"\">Stream" | sed 's/Télécharger<\/a> - <a href=\"//' | sed 's/\#stream\">Stream//' | grep -oP "\/".*?"\/" | sed 's/\///g') #also ugly. and needs perl
#echo $anime_eps_raw #DEBUG

IFS=$'\n' read -rd '' -a anime_eps <<<"$anime_eps_raw" # explode anime_eps
echo "Found ${#anime_eps[@]} episodes"

ep_counter=0

for i in "${anime_eps[@]}"
do
	((ep_counter++)) # increment episode counter to 1
	echo "Downloading episode $ep_counter/${#anime_eps[@]} (ID $i)" #$i is episode ID
	echo "Asking server for auth..."
	raw_server_resp=$(curl --silent --data "idfile=$i&type=orig" $base_url/ddl/authorized_download.php) #ask the server for our status. If not auth, will respond : '{"auth":false,"wait":0,"iduser":-1}' if auth : {"auth":true,"link":"\/ddl\/24348\/orig\/Nanoha S2 - 01 {Requiem DvD}{B3185263}.avi","wait":0,"iduser":-1}
	#echo "$raw_server_resp" #DEBUG
	is_auth=$(echo "$raw_server_resp" | grep -oP "\{\"".*?"\," | sed 's/{\"auth\"://' | sed 's/\,//') #report true/false if we are auth on the server or not
	if [ "$is_auth" = "false" ]; then
		delay=$(echo "$raw_server_resp" | grep -oP "wait".*?"\iduser" | sed 's/wait\"://' | sed 's/\,\"iduser//') #if not auth, wait will be non-null.
		echo "We have to wait $delay s to be authed on server"
		echo "Press S to skip this episode"
		while [ $delay -gt 0 ]; do
		   echo -ne "Remaining time to wait : $delay\033[0K\r"
		   #sleep 1
		   read -t 1 -n 1 key #every 1s, read input buffer to see a key was pressed
    		   if [[ $key = s ]]; then
			skip=1 #we set skip=1 to exit the main for loop
        		break #we exit this waiting loop
    		   fi
		   : $((delay--))
		done
		if [ "$skip" = "1" ]; then
			skip=0 #unset $skip so that the script downloads the next episode
			echo "Skipping this episode"
			echo " "
			continue #we exit the main for loop
		fi
		echo "Waiting 5 more seconds, just to be sure"
		sleep 5 #add 5 more s just to be sure
	elif [ "$is_auth" = "true" ]; then
		echo "Already authed, ready to download"
	else
		echo "ERROR : server answer can't be parsed"
		echo "Server answered : $raw_server_resp"
		echo "EXITING"
		exit
	fi
	
	echo "Asking server for download link..."
	dl_link_suffix=$(curl --silent --data "idfile=$i&type=orig" $base_url/ddl/authorized_download.php | grep -oP "\"link\"".*?"\," | sed 's/\"link\":\"//' | sed 's/\"\,//' | sed 's/\\//g') # $base_url has to be added before this string to get the download url
	dl_link=$base_url$dl_link_suffix
	#echo $dl_link #DEBUG
	filename=$(echo "$dl_link_suffix" | rev | cut -d'/' -f 1 | rev) #get filename (last field of dl_link_suffix)
	echo "Downloading episode $ep_counter/${#anime_eps[@]} : $filename"
	#curl --progress-bar -L "$dl_link" --output "$filename"
	wget -q -c --show-progress -T 15 "$dl_link" -O "$filename" #IF YOU WANT TO USE WGET UNCOMMENT THIS LINE AND COMMENT THE LINE ABOVE
	echo "Next episode"
	echo ""
done

echo "END"
exit
