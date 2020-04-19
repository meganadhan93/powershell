# For apache 

compress
compresscmd /bin/gzip
compressoptions -9
compressext .gz

dateext
dateformat -%Y-%m-%d-%s

rotate 7
maxage 7
nomail
missingok
daily
size 5k
create 640 username username

/var/logs/test.local/*.log {
sharedscripts
postrotate
sudo /usr/sbin/apache2ctl graceful

/usr/bin/s3cmd sync /var/logs/test.local/*.gz s3://bucket-logs/test.local/
endscript
}




# Backup Cron
0 0 * * * /usr/sbin/logrotate --state /home/username/scripts/log_rotate.state /home/username/scripts/log_rotate.config

# For Mysql:

compress
compresscmd /bin/gzip
compressoptions -9
compressext .gz

dateext
dateformat -%Y-%m-%d-%s

rotate 7
maxage 7
nomail
missingok
daily
size 5k
create 640 username username

/var/log/mysql/* {
sharedscripts
postrotate
if test -x /usr/bin/mysqladmin && \
           /usr/bin/mysqladmin ping &>/dev/null
        then
           /usr/bin/mysqladmin --local flush-error-log \
              flush-engine-log flush-general-log flush-slow-log

  fi
    
/usr/bin/s3cmd sync /var/logs/mysql/*.gz s3://bucket-logs/test.local/
endscript
}




