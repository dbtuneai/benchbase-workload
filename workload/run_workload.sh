#!/bin/bash
BENCHMARK_VARIATION=${BENCHMARK_VARIATION:-$BENCHMARK}

# Modifying the benchbase configuration files
JDBC_CONNECTION_STRING="jdbc:postgresql://${TUNING_POSTGRES_HOST}:${TUNING_POSTGRES_PORT}/${TUNING_POSTGRES_DB}?ApplicationName=$BENCHMARK&amp;reWriteBatchedInserts=true"

JDBC_URL=$(sed 's/[&/]/\\&/g' <<< "$JDBC_CONNECTION_STRING")

sed -i 's/connection_string/'"$JDBC_URL"'/g' ./config/postgres/sample_${BENCHMARK_VARIATION}_config.xml
sed -i 's/dbuser/'"$TUNING_POSTGRES_USER"'/g' ./config/postgres/sample_${BENCHMARK_VARIATION}_config.xml
sed -i 's/dbpassword/'"$TUNING_POSTGRES_PASSWORD"'/g' ./config/postgres/sample_${BENCHMARK_VARIATION}_config.xml

python3 runner.py \
 --benchmark ${BENCHMARK} \
 --variation ${BENCHMARK_VARIATION} \
 --warmup-time-seconds ${WARMUP_TIME_SECONDS} \
 --skip-create-and-load ${SKIP_CREATE_AND_LOAD}