#!/bin/bash
#Author: Luca Santirocchi
#Version 1
#Post Backup OCP script

#set backup script variable
DATE=`date -I`
DIR=/Backup_OCS/backup/$(hostname)
DIR=$DIR/$DATE

#backup error generate dir with about 8KB = 8192 byte
SizeWithErr=8192

#check dir size, if are greater than 8Kb OK, else backup in error
size=$(du -bs "$DIR" | cut -f1)

if [ "$size" -le "$SizeWithErr" ];
then
    echo "Backup KO" &> /Backup_OCS/backup/check_backup_ocp_post.log
else
    echo "Backup OK" &> /Backup_OCS/backup/check_backup_ocp_post.log
    echo "remove files and directories older than 30 days"
    find /Backup_OCS/backup/$(hostname)/ -type d -mtime +30 -exec rmv -rf {} \;
    find /Backup_OCS/backup/ -type f -name "*.log" -mtime +30 -exec rmv -rf {} \;
    echo "Files and directories older than 30 days removed"
fi
