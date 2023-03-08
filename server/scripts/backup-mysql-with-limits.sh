echo '----------------'
echo 'Start backup'
echo '----------------'

echo `date`

DAY=`date +%Y-%m-%d-%H-%M`
ROOT="/home/naxchivan/db_back"
DUMP="$ROOT/backup.sql"
BACKUP="$ROOT/$DAY.tar.gz"

echo 'Database backup start'

# DUMP
mkdir -p $ROOT
cd $ROOT
nice -n 10 ionice -c2 -n 7 docker exec -i mysql mysqldump -u reader -pzJcc3LwkyBLh7jmH --all-databases --single-transaction --quick | gzip > $BACKUP
#/usr/bin/cpulimit --limit=10 /usr/bin/tar -czf $BACKUP $DUMP
#tar cf - $DUMP | pigz -6 -p 2 > $BACKUP
#/bin/rm $DUMP
echo "Database dump complete"

echo "Clean up..."
find $ROOT/ -mtime +1 -exec rm {} \;

echo '----------------'
echo `date`
echo 'END'