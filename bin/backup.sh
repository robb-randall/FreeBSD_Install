#!/bin/sh
base_dir=$HOME/Backups
backup_dir=${base_dir}/$(date +'%Y-%m-%d')
backup_file=${backup_dir}/$(date +'%Y-%m-%d')
history_file=${base_dir}/_history.log

echo "$(date +"%Y-%m-%d %H:%M:%S") : ${backup_file}" >> $history_file

mkdir -p $backup_dir

tar -zcvf $backup_file.tgz \
	--exclude ~/Backups \
	--exclude ~/Books \
	--exclude ~/Downloads \
	--exclude ~/Repositories \
	--exclude ~/go \
	--exclude ~/.gem \
	--exclude ~/.rvm \
	--exclude ~/.cache \
	$HOME 2>&1 | tee $backup_file.log

exit 0;
