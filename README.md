# YouTube_Archive
These scripts will fully automate downloading YouTube channels and uploading them to Google Drive, or a local storage path if you choose. Just input the channel URL(s) to the List_of_Links text file and set the script to run as a cron job! These scripts also integrate with MailGun, allowing it to send email updates to you upon script completion or failure. The scripts also use Rclone to upload the downloaded files to google drive, allowing you to keep an online copy of the videos. This feature is optional, and can be disabled by simply deleting the YouTube_Backup script. Lastly, these scripts keep a record of what has been downloaded, allowing you to use the same command/cronjob to keep the channels up to date with new videos without downloading everything again!

The script is layed out in the following way:
- Starts a loop and pulls first channel from file
- Create new directories
- Download the videos and metadata
- Convert all videos to same format (.mkv)
- Sends a email using Mailgun
- Repeat until all channels are downloaded
