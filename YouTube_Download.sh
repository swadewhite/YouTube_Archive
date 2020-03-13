#!/bin/bash

# Variable Time!

# Path Variables
SCRIPT_DIR=/path/to/script/folder
DOWNLOAD_DIR=/path/to/download/directory

# MailGun Variables (To send email updates)
MG_API='api:YOUR_API_KEY'
MG_URL="https://api.mailgun.net/v3/YOUR_URL/messages"
MG_FROM='Download Server <mailgun@YOUR_MAILGUN_ADDRESS>'
MG_TO='DESTINATION_EMAIL'


# Sort the links in alphabetical order (For neatness)
sudo sort $SCRIPT_DIR/List_of_Links.txt

# Start loop to read through the links file.
while read CURRENT; do

# Finds the channel name and link to it.
NAME=$(echo "$CURRENT" | cut -d, -f1)
LINK=$(echo "$CURRENT" | cut -d, -f2)

# Creates new folders for the channel.
sudo mkdir $DOWNLOAD_DIR/"$NAME"
sudo mkdir $DOWNLOAD_DIR/"$NAME"/Thumbnails

# Makes a file that will tell the upload script to skip this channel because it is still downloading.
sudo touch $DOWNLOAD_DIR/"$NAME"/status.txt
sudo echo "inprogress" > $DOWNLOAD_DIR/"$NAME"/status.txt

# Downloads all the videos, subtitles, thumbnails and stores the video-id in a file.
sudo youtube-dl -ciw -o $DOWNLOAD_DIR/"$NAME"/"%(playlist_index)s_%(title)s.%(ext)s" $LINK --playlist-reverse --add-metadata --write-thumbnail --embed-thumbnail --embed-subs --all-subs --no-progress --download-archive $DOWNLOAD_DIR/"$NAME"/titles.txt

# Converts all mp4 and webm files to the mkv container for consistancy.
cd $DOWNLOAD_DIR/"$NAME"
for i in *.mp4;
  do name=`echo "$i" | cut -d'.' -f1`
  echo "$name"
  ffmpeg -i "$i" -c copy "${name}.mkv" -n
done
for i in *.webm;
  do name=`echo "$i" | cut -d'.' -f1`
  echo "$name"
  ffmpeg -i "$i" -c copy "${name}.mkv" -n
done

# Moves all downloaded thumbnails to a folder.
sudo find $DOWNLOAD_DIR/"$NAME"/ -name '*jpg' -exec mv -t $DOWNLOAD_DIR/"$NAME"/Thumbnails {} +

# Deletes all remaining junk files.
sudo find . -name "*.mp4" -type f -delete
sudo find . -name "*.webm" -type f -delete

# Tells status.txt that the download is done and can now be uploaded.
sudo truncate -s 0 $DOWNLOAD_DIR/"$NAME"/status.txt
sudo echo "done" > $DOWNLOAD_DIR/"$NAME"/status.txt

# Sends an email using MailGun
curl -s --user $MG_API \
	$MG_URL \
	-F from=$MG_FROM \
	-F to=$MG_TO \
	-F subject='YouTube-DL Download Status' \
	-F text="All of ${NAME}'s channel was downloaded and will to upload to Google Drive at the next opportunity."

# Ends the loop.
done <$SCRIPT_DIR/List_of_Links.txt
