#!/bin/bash

export MYSQL_PWD=$MYSQL_ROOT_PASSWORD

while true
do
  echo "Getting Data from GEOIP Portal"
  curl --create-dirs -sSLo /tmp/json/test1.json http://freegeoip.net/json/

function getPropValue() {
  KEY=$1;
  num=$2;
  awk -F "[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p;
}

echo "Parsing GEOPIP Data";
ip=$(cat /tmp/json/test1.json|getPropValue ip);
country_code=$(cat /tmp/json/test1.json|getPropValue country_code);
country_name=$(cat /tmp/json/test1.json|getPropValue country_name);
region_code=$(cat /tmp/json/test1.json|getPropValue region_code);
region_name=$(cat /tmp/json/test1.json|getPropValue region_name);
city=$(cat /tmp/json/test1.json|getPropValue city);
zip_code=$(cat /tmp/json/test1.json|getPropValue zip_code);
time_zone=$(cat /tmp/json/test1.json|getPropValue time_zone);
latitude=$(cat /tmp/json/test1.json|getPropValue latitude);
longitude=$(cat /tmp/json/test1.json|getPropValue longitude);
metro_code=$(cat /tmp/json/test1.json|getPropValue metro_code);

echo "Inserting parsed Data into mysql database";
mysql -uroot mysqldb << EOF
CREATE TABLE IF NOT EXISTS geoipdata
(
SNO INT AUTO_INCREMENT NOT NULL UNIQUE,
ip VARCHAR(15),
country_code VARCHAR(20),
country_name VARCHAR(20),
region_code VARCHAR(20),
region_name VARCHAR(20),
city VARCHAR(20),
zip_code INT,
time_zone VARCHAR(20),
latitude DECIMAL(10,8),
longitude DECIMAL(10,8),
metro_code BIGINT UNSIGNED
);

INSERT INTO geoipdata SET ip="$ip",country_code="$country_code",country_name="$country_name",region_code="$region_code",region_name="$region_name",city="$city",zip_code="$zip_code",time_zone="$time_zone",latitude="$latitude",longitude="$longitude",metro_code="$metro_code";
EOF

echo "done";
rm -rf /tmp/json
sleep 60;
done;
