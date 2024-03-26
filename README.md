# Linux Cluster Monitoring Project

## Introduction
 
 This project is developed to support Linux CLuster Administration (LCA) team which collects data from linux cluster node for monitoring purpose, generating reports and make needful decisions.
 The project basically allows the team to record hardware specifications of linux nodes and its memory usage information in real time.
 List of potential users and technologies used are as follows :
 
 ### Users
 - Network administrators
 - Analysts
 - System Administrators
 
 ### Technologies
 - Docker
 - Shell scripts
 - PostgreSQL
 - Git
 
 ## Quick Start
- Start a psql instance using psql_docker.sh
```shell script
# create a container if not exists
./scripts/psql_docker.sh start|stop|create [db_username][db_password]
# start the container
./scripts/psql_docker.sh start
# connect to a psql instance
psql -h HOST_NAME -p 5432 -U USER_NAME
```
- Create tables using ddl.sql
```sql/
-- Create a host_info table
CREATE TABLE PUBLIC.host_info 
  ( 
     id               SERIAL NOT NULL, 
     hostname         VARCHAR NOT NULL, 
     cpu_number       INT2 NOT NULL, 
     cpu_architecture VARCHAR NOT NULL, 
     cpu_model        VARCHAR NOT NULL, 
     cpu_mhz          FLOAT8 NOT NULL, 
     l2_cache         INT4 NOT NULL, 
     "timestamp"      TIMESTAMP NULL, 
     total_mem        INT4 NULL, 
     CONSTRAINT host_info_pk PRIMARY KEY (id), 
     CONSTRAINT host_info_un UNIQUE (hostname) 
  );

-- Create a host_usage table
CREATE TABLE PUBLIC.host_usage 
  ( 
     "timestamp"    TIMESTAMP NOT NULL, 
     host_id        SERIAL NOT NULL, 
     memory_free    INT4 NOT NULL, 
     cpu_idle       INT2 NOT NULL, 
     cpu_kernel     INT2 NOT NULL, 
     disk_io        INT4 NOT NULL, 
     disk_available INT4 NOT NULL, 
     CONSTRAINT host_usage_host_info_fk FOREIGN KEY (host_id) REFERENCES 
     host_info(id) 
  );
```
- Insert hardware specs data into the DB using host_info.sh
```sql
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem)
                VALUES('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"
```
- Insert hardware usage data into the DB using host_usage.sh
```sql
insert_stmt="INSERT INTO host_usage (timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
              VALUES('$timestamp',$host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"
```
- Crontab setup
```shell script
# edit crontab jobs
bash> crontab -e
# add this to crontab
* * * * * bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```

## Implementation
Initially, a git repository on Github is generated to save the source code. Docker is installed on the remote desktop, through which a container gets created with proper volume to persist data.
With the help of container, PostgreSQL is pulled to make database schema. Two tables are created host_info and host_usage in the host_agent database. After setting up database, bash scripts 
are prepared to gather hardware specifications and host usage information. After this information gets inserted into database, host_usge script is automated to fetch the values within the interval of each minute.
This task is carried out with the command-line utility called crontab. It schedules the jobs at certain times ori intervals. After necessary changes, hotfixes and solving typos, the project gets deployed on github.


## Architecture
Below is the linux cluster architecture diagram consisting three linux nodes, a host agent and a database.

<img alt="Linux Cluster Administration diagram" src="C://Users//dell//Downloads//jarvis_data_eng_KhushaliMehta-develop//jarvis_data_eng_KhushaliMehta-develop//assets//linux_arch.jpg" width="400" height="450">

## Scripts

- psql_docker.sh - The script will perform creation task of the required container if not exists. It will start and stop the container according to the user needs.
```shell script
# script usage
./scripts/psql_docker.sh start|stop|create [db_username][db_password]

```
- host_info.sh - This script will collect hardware specifications such as number of CPUs, Model name, Architecture and so on. It utilizes the host_info table to inject the data.
```shell script
# script usage
./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password
```
- host_usage.sh - It is used to get the usage information like disk I/O, available disk in MB, timestamp and much more. The script then constucts and executes INSERT statement to store data in host_usage table.
```shell script
bash scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password
```
- crontab - Cron is a linux utility which works like a job schedular. Host_usage.sh script is executed every minute by this utility, thus data gets added to the database within time-intervals. 
Here the five (*) states that job will run each minute.
```shell script
# to execute the job at a moment, use this in CLI
bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```
- queries.sql  - Users will execute some SQL queries to pull out information like average usage time in percentage over one minute intervals. They can also retrieve a list of all distinct host_names which are stored in the database and fetch specific information of hosts.

### READ.me in progress