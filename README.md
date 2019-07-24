# SH-Anime-Ultime-Downloader
A bash script to download an entire season of an anime on the french website Anime Ultime
 
WARNING : at the moment, this script does NOT do any kind of error handling.  
Also, at the moment, this script can only download a whole season, you can skip every ep that you don't want to download, but you have to give/use the link for the full season.  
- if the URL contains `file-*-*` (* = numbers), it's the link for the full season, you CAN use this  
(example : http://www.anime-ultime.net/file-0-1/2426/Mahou-Shoujo-Lyrical-Nanoha-A039s-vostfr)
- if the URL contains `info-*-*` (* = numbers), it's the link for only on ep, you CAN'T use this
(exmaple : http://www.anime-ultime.net/info-0-1/24348/Mahou-Shoujo-Lyrical-Nanoha-A039s-01-vostfr)

To use it, you need :
- bash (obviously)
- wget >=1.16
- curl 
- grep **with perl regex support**
- sed
- cut
- iconv 
 
(*grep*, *sed*, *iconv* and *cut* should already be installed on your distro) 

Usage :  
```./anime-ultime-dler.sh url_to_anime_episodes_list```
For example, if i want to download the season 2 of Lyrical Nanoha : http://www.anime-ultime.net/file-0-1/2426/Mahou-Shoujo-Lyrical-Nanoha-A039s-vostfr  
```./anime-ultime-dler.sh http://www.anime-ultime.net/file-0-1/2426/Mahou-Shoujo-Lyrical-Nanoha-A039s-vostfr```
  
This script works by parsing the webpage to get the ID of every episode, asking the server to auth the IP, the server will answer a delay $x in seconds, we wait $x+5 seconds, we ask the server again, the server should answer the URL of the file we want to download. We HAVE to wait, or else the server will not give the download URL. -> If you want to learn more about this, read the .sh file, you should be able to understand how it's working.
  
(sorry for my bad english, feel free to correct me)
