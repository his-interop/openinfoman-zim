#!/bin/sh
#for backing up basex databases, automatically
# fannuel wamambo, Ryan Crichton
#basex home
app_name="hitrac_basex"
basex_home="/opt/basex"
backup_dir="$basex_home/data"
database_name="provider_registry"
backup_filename=$app_name-backup-`date +%Y-%m-%d-%H.%M%P`
backup_filename_tar=$backup_filename".tar.gz"
#
#now the actual work
cd $basex_home/bin
echo "backing up $database_name into $backup_dir/$backup_filename"
./basex -i $database_name -c "export $backup_dir/$backup_filename"
# tar the backup files
cd $backup_dir && tar czf $backup_filename_tar $backup_filename
rm -rf $backup_dir/$backup_filename
# 
# Cleanup old backup filess
#  - keep previous 30 days backups and the backup from the first of every month
#filename example hitrac_basex-backup-2014-06-27-10.45am.tar.gz
find $backup_dir -name "$app_name-backup-*" -mtime +30 -not -name "$app_name-backup-*-01.tar.gz" -exec rm {} \;
#
# now, lets copy the files somewhere
remote_user=""
remote_pass=""
#the passwd part can be sorted by ssh-keygen export
remote_host=""
remote_dir=""
echo "Copying $backup_dir backup files in $backup_dir to remote server: " $remote_host
scp $backup_dir/$backup_filename_tar $remote_user@$remote_host:$remote_dir
#
#
