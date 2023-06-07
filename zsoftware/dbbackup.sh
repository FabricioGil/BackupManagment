# use mysql_config_editor to obfuscate the credentials


DB_USER="fgil"
DB_NAME="cavi"
BACKUP_DIR="/home/fgil/sqldumps"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
mysqldump --login-path=client -p --databases $DB_NAME >$BACKUP_DIR/$DB_NAME-$DATE.sql
gzip $BACKUP_DIR/$DB_NAME-$DATE.sql
find $BACKUP_DIR -type f - name "*.gz" -mtime +14 -delete

# crontab config 

# 0 23 * *  MON,WED,FRI sh /path