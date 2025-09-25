"""This is the data loader. It wraps the benchbase data loader with some convenience features."""

import argparse
import logging
import subprocess
import sys
import threading

logging.basicConfig(
    level=logging.INFO,  # Set to desired logging level
    format="%(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

logger = logging.getLogger(__name__)


def parse_true_false_string(s: str) -> bool:
    value = s.lower()
    if value == "true" or value == "1":
        return True
    elif value == "false" or value == "0":
        return False
    else:
        raise ValueError(f"Invalid boolean string: {s}")


parser = argparse.ArgumentParser()
parser.add_argument(
    "--skip-create-and-load",
    help="Whether to skip creating and loading the database.",
    required=True,
    type=parse_true_false_string,
)
parser.add_argument(
    "--warmup-time-seconds",
    help="The warmup time in seconds.",
    required=True,
    type=int,
)
parser.add_argument(
    "--benchmark",
    help="Select a benchmark from epinions, tpch and resourcestresser.",
    required=True,
    type=str,
)
parser.add_argument(
    "--variation",
    help="Select appropriate config. defaults to same as --benchmark if not provided",
)


args = parser.parse_args()
print(args)
if args.variation is None:
    args.variation = args.benchmark
benchmark = args.benchmark
variation = args.variation


def bench(commands):
    java_args = [
        "-Xmx5g",  # Maximum heap size
        "-XX:+UseG1GC",  # Use the Garbage-First (G1) Garbage Collector
        "-XX:G1HeapRegionSize=4M",  # Set G1 heap region size
        "-XX:MaxGCPauseMillis=200",  # Set maximum GC pause time
        "-XX:ParallelGCThreads=4",  # Set number of parallel GC threads
        "-XX:+HeapDumpOnOutOfMemoryError",  # Enable heap dump on OOM error
        "-XX:HeapDumpPath=/tmp/heapdump",  # Specify heap dump path
    ]
    benchmark_command = [
        "java",
        *java_args,
        "-jar",
        "benchbase.jar",
        "-b",
        benchmark,
        "-c",
        f"benchbase-postgres/config/postgres/sample_{variation}_config.xml",
        commands,
        "-s",
        "5",
    ]
    return subprocess.run(benchmark_command, cwd="/workload").returncode


def create_done_file():
    logger.info("Creating .done file.")
    with open("/workload/benchbase-postgres/.done", "w") as file:
        file.write("Health check passed.")


if __name__ == "__main__":
    try:
        if args.skip_create_and_load:
            logger.info(
                "Benchbase: Executing workload using the mounted data directory."
            )
        else:
            logger.info("Benchbase: Loading data.")
            bench("--create=true")
            bench("--load=true")

        logger.info("Start benchmark execution.")

        # Set a timer to create the .done file after the warmup time has expired
        wait = args.warmup_time_seconds
        timer = threading.Timer(wait, create_done_file)
        timer.start()
        while True:
            return_code = bench("--execute=true")
            if return_code != 0:
                break
    except KeyboardInterrupt:
        sys.exit(0)
