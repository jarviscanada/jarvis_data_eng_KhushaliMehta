#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#have to start container otherwise it won't allow to connect to the psql through the port
docker container start jrvs-psql

vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

memory_free=$(vmstat --unit M | tail -1 | awk -v col="4" '{print $col}')
cpu_idle=$(vmstat --unit M | tail -1 | awk -v col="15" '{print $col}')
cpu_kernel=$(vmstat --unit M | tail -1 | awk -v col="14" '{print $col}')
disk_io=$(vmstat --unit M -d | tail -1 | awk -v col="10" '{print $col}')
disk_available=$(df -BM / | awk 'NR==2 {print $4}' | sed 's/M//')
timestamp=$(date "+%Y-%m-%d %H:%M:%S")


host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";

insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
              VALUES('$timestamp',$host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

export PGPASSWORD=$psql_password

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

docker container stop jrvs-psql


exit $?