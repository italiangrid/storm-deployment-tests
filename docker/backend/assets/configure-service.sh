#!/bin/bash

# do yaim
/opt/glite/yaim/bin/yaim -c -s /etc/storm/siteinfo/storm.def -n se_storm_backend

# do fixture
sh ./fixture.sh ${TARGET_RELEASE}

# print JSON report
/usr/libexec/storm-info-provider get-report-json
cat /etc/storm/info-provider/site-report.json

# fix db grants for root@'fqdn' if needed
source /assets/scripts/${TARGET_RELEASE}/siteinfo/storm.def
mysql -u root -p${MYSQL_PASSWORD} -e"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES" #> /dev/null 2> /dev/null
