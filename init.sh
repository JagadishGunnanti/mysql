#!/bin/bash

export MYSQL_PWD=$MYSQL_ROOT_PASSWORD

while true
do
  echo "Getting Data from GEOIP Portal"
  curl --create-dirs -sSLo /tmp/json/test1.json "http://api.ipstack.com/check?access_key=172df12a080da70c155b5203e8d7769b"

function getPropValue() {
  KEY=$1;
  num=$2;
  awk -F "[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p;
}

echo "Parsing GEOIP Data";
continent_code=$(cat /tmp/json/test1.json|getPropValue continent_code);
country_code=$(cat /tmp/json/test1.json|getPropValue country_code);
country_name=$(cat /tmp/json/test1.json|getPropValue country_name);
region_code=$(cat /tmp/json/test1.json|getPropValue region_code);
region_name=$(cat /tmp/json/test1.json|getPropValue region_name);
city=$(cat /tmp/json/test1.json|getPropValue city);
latitude=$(cat /tmp/json/test1.json|getPropValue latitude);
longitude=$(cat /tmp/json/test1.json|getPropValue longitude);

echo "Inserting parsed Data into mysql database";
mysql -uroot mysqldb << EOF
CREATE TABLE IF NOT EXISTS geoipdata
(
SNO INT AUTO_INCREMENT NOT NULL UNIQUE,
continent_code VARCHAR(20),
country_code VARCHAR(20),
country_name VARCHAR(20),
region_code VARCHAR(20),
region_name VARCHAR(20),
city VARCHAR(20),
latitude DECIMAL(10,8),
longitude DECIMAL(10,8)
);

INSERT INTO geoipdata SET continent_code="$continent_code",country_code="$country_code",country_name="$country_name",region_code="$region_code",region_name="$region_name",city="$city",latitude="$latitude",longitude="$longitude";
EOF

echo "done";
rm -rf /tmp/json
sleep 60;
done;
