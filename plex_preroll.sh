#!/bin/bash

#get current month
month=$(date +%B)

#used to select any files listed for the preroll section of the Plex Prefences.xml
roll_to_change='CinemaTrailersPrerollID=".*" Butler'

#generates the preroll list basead on availalbe month, if no available month, use default folder
if [ -d "/mnt/user/Media/media/misc/preroll/$month" ]; then
    cd /mnt/user/Media/media/misc/preroll/$month
    find . -type f -name "*.mp4" | cut -c 3- > preroll_draft.txt
    sed -i "s|^|/data/media/misc/preroll/$month/|g" preroll_draft.txt
else
    cd /mnt/user/Media/media/misc/preroll/default
    find . -type f -name "*.mp4" | cut -c 3- > preroll_draft.txt
    sed -i "s|^|/data/media/misc/preroll/default/|g" preroll_draft.txt
fi

#formats the listing to be put in the Preferences.xml as videos seperated by semi-colons
tr '\n' ';' < preroll_draft.txt > preroll.txt
rm -r preroll_draft.txt
truncate -s-1 preroll.txt
file_output=$(cat preroll.txt)
rm -r preroll.txt

#updating the Plex Preferences.xml file
update_roll='CinemaTrailersPrerollID="'"${file_output}"'" Butler'
sed -i "s|$roll_to_change|$update_roll|g" "/mnt/user/appdata/Plex-Media-Server/Library/Application Support/Plex Media Server/Preferences.xml"

#restart Plex docker for changes to take affect
docker restart Plex-Media-Server
