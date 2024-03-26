-- Switch to `host_agent` database is typically done outside of the SQL script
-- and handled by the psql command line utility as shown in the execution command

-- Create `host_info` table if not exists
CREATE TABLE IF NOT EXISTS host_info (
                                         id SERIAL NOT NULL,
                                         hostname VARCHAR NOT NULL,
    cpu_number INT2 NOT NULL,
    cpu_architecture VARCHAR NOT NULL,
    cpu_model VARCHAR NOT NULL,
    cpu_mhz FLOAT8 NOT NULL,
    L2_cache INT4 NOT NULL,
    "timestamp" TIMESTAMP NULL,
    total_mem INT4 NULL,
    CONSTRAINT host_info_pk PRIMARY KEY (id) ,
    CONSTRAINT host_info_un UNIQUE (hostname)
    );

-- Create `host_usage` table if not exists
    CREATE TABLE IF NOT EXISTS host_usage (
                                              "timestamp" TIMESTAMP NOT NULL,
                                              host_id SERIAL NOT NULL,
                                              memory_free INT4 NOT NULL,
                                              cpu_idle INT2 NOT NULL,
                                              cpu_kernel INT2 NOT NULL,
                                              disk_io INT4 NOT NULL,
                                              disk_available INT4 NOT NULL,
        CONSTRAINT host_usage_host_info_fk FOREIGN KEY (host_id) REFERENCES host_info(id)
    );
