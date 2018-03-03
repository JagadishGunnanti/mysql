#!/bin/bash
mysql -uroot -pmysqlpassword mysqldb <<EOF
EOF
echo "dumping json data"
while true
do
curl --create-dirs -sSLo /tmp/json/test.json http://freegeoip.net/json/
mysql -uroot -pmysqlpassword mysqldb << EOF
CREATE TABLE IF NOT EXISTS jsons_test(
       ID INT AUTO_INCREMENT NOT NULL UNIQUE,
               json_data json);
               LOAD DATA LOCAL INFILE '/tmp/json/test.json'
               INTO table jsons_test(json_data);
EOF
sleep 60
done
