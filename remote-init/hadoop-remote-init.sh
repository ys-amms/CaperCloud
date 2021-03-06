#!/usr/bin/env bash

HADOOP_HOME="/usr/local/hadoop-1.2.1"
MASTER_IP=$1
HOST_NAME=`hostname`

cat > $HADOOP_HOME/conf/core-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/mnt/hadoop</value>
        <description>A base for other temporary directories.</description>
    </property>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://$MASTER_IP:9000</value>
    </property>
</configuration>
EOF

cat > $HADOOP_HOME/conf/hdfs-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
</configuration>
EOF

cat > $HADOOP_HOME/conf/mapred-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>mapred.job.tracker</name>
        <value>http://$MASTER_IP:9001</value>
    </property>
</configuration>
EOF

for HOST in `cat $HADOOP_HOME/conf/slaves`
    do
        if  [ -n $HOST ] && [[ $HOST != $HOST_NAME ]]; then
            while true; do
                scp $HADOOP_HOME/conf/core-site.xml $HOST:$HADOOP_HOME/conf
                myResult=$?
                if [ $myResult -eq 0 ]; then
                    break
                else
                    echo "Retrying scp...sleep 5s"
                    sleep 5
                fi
            done
            scp $HADOOP_HOME/conf/hdfs-site.xml $HOST:$HADOOP_HOME/conf
            scp $HADOOP_HOME/conf/mapred-site.xml $HOST:$HADOOP_HOME/conf
            scp $HADOOP_HOME/conf/masters $HOST:$HADOOP_HOME/conf
            scp $HADOOP_HOME/conf/slaves $HOST:$HADOOP_HOME/conf
        fi
    done

[ ! -e /mnt/hadoop/dfs ] && "$HADOOP_HOME"/bin/hadoop namenode -format
"$HADOOP_HOME"/bin/start-all.sh

