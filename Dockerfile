FROM maven:3-eclipse-temurin-23 AS devcontainer

ARG BENCHBASE_COMMIT=4ac0750aa9ef23be6491df3e008b74010f0c2f70

# Make sure the image is patched and up to date.
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y update \
    && apt-get -y install --no-install-recommends git python3 python3-pip postgresql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages psycopg2-binary


# Clone and build benchbase in separate layers for better caching
RUN git clone --depth 1 --single-branch https://github.com/cmu-db/benchbase.git && \
    cd benchbase && \
    git fetch --depth 1 origin ${BENCHBASE_COMMIT} && \
    git checkout ${BENCHBASE_COMMIT} && \
    rm -rf .git

# Build benchbase with optimized Maven settings
RUN cd benchbase && \
    env -u MAVEN_CONFIG -u MAVEN_OPTS ./mvnw clean package -P postgres -Dmaven.test.skip=true && \
    cd target && tar xvzf benchbase-postgres.tgz && \
    mv benchbase-postgres /workload/ && \
    cd / && rm -rf benchbase

# Copy frequently changing files last to preserve cache for expensive operations above
COPY workload/runner.py /workload/benchbase-postgres/runner.py
COPY workload/run_workload.sh /workload/benchbase-postgres/run_workload.sh
COPY workload/configs/*.xml /workload/benchbase-postgres/config/postgres/

WORKDIR /workload/benchbase-postgres
RUN chmod +x run_workload.sh
CMD ["./run_workload.sh"]
