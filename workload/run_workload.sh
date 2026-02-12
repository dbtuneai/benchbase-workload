#!/bin/bash
BENCHMARK_VARIATION=${BENCHMARK_VARIATION:-$BENCHMARK}
BENCHMARK_WORK_RATE=${BENCHMARK_WORK_RATE:-unlimited}
BENCHMARK_SCALE_FACTOR=${BENCHMARK_SCALE_FACTOR:-}
BENCHMARK_TERMINALS=${BENCHMARK_TERMINALS:-}

CONFIG_FILE=./config/postgres/sample_${BENCHMARK_VARIATION}_config.xml


# Modifying the benchbase configuration files
JDBC_CONNECTION_STRING="jdbc:postgresql://${TUNING_POSTGRES_HOST}:${TUNING_POSTGRES_PORT}/${TUNING_POSTGRES_DB}?ApplicationName=$BENCHMARK&amp;reWriteBatchedInserts=true"

JDBC_URL=$(sed 's/[&/]/\\&/g' <<< "$JDBC_CONNECTION_STRING")

sed -i "s/connection_string/$JDBC_URL/g" $CONFIG_FILE
sed -i "s/dbuser/$TUNING_POSTGRES_USER/g" $CONFIG_FILE
sed -i "s/dbpassword/$TUNING_POSTGRES_PASSWORD/g" $CONFIG_FILE
sed -i "s|<rate>.*</rate>|<rate>${BENCHMARK_WORK_RATE}</rate>|g" $CONFIG_FILE
if [ -n "$BENCHMARK_SCALE_FACTOR" ]; then
    sed -i "s|<scalefactor>.*</scalefactor>|<scalefactor>${BENCHMARK_SCALE_FACTOR}</scalefactor>|g" $CONFIG_FILE
fi
if [ -n "$BENCHMARK_TERMINALS" ]; then
    sed -i "s|<terminals>.*</terminals>|<terminals>${BENCHMARK_TERMINALS}</terminals>|g" $CONFIG_FILE
fi

python3 runner.py \
 --benchmark ${BENCHMARK} \
 --variation ${BENCHMARK_VARIATION} \
 --warmup-time-seconds ${WARMUP_TIME_SECONDS} \
 --skip-create-and-load ${SKIP_CREATE_AND_LOAD}