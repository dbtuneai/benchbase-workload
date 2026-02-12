# BenchBase Workload Runner

A Docker-based workload runner for [BenchBase](https://github.com/cmu-db/benchbase), the multi-DBMS SQL benchmarking framework. This container provides an easy way to run standardized database benchmarks against PostgreSQL databases.

## Overview

This project packages BenchBase with a Python runner that provides convenient workload execution with configurable parameters. It supports multiple benchmark types and can be used for database performance testing and tuning experiments.

## Supported Benchmarks

- **AuctionMark** - Auction site (e.g. eBay) OLTP workload
- **TPCC** - TPC-C online transaction processing benchmark
- **TPCH** - TPC-H decision support benchmark
- **TPCH5** - TPC-H variant with 5 concurrent streams
- **Epinions** - Review site workload
- **SEATS** - Airline ticket management OLTP workload
- **ResourceStresser** - Resource stress testing workload

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dbtuneai/benchbase-workload.git
   cd benchbase-workload
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.template .env
   # Edit .env with your database configuration
   ```

3. **Build the Docker image:**
   ```bash
   docker build -t benchbase-workload .
   ```

4. **Run a benchmark:**
   ```bash
   docker run --rm --env-file .env benchbase-workload
   ```

## Configuration

### Environment Variables

Copy `.env.template` to `.env` and configure the following variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `TUNING_POSTGRES_HOST` | PostgreSQL host | `localhost` |
| `TUNING_POSTGRES_PORT` | PostgreSQL port | `5432` |
| `TUNING_POSTGRES_DB` | Database name | `benchbase` |
| `TUNING_POSTGRES_USER` | Database user | `postgres` |
| `TUNING_POSTGRES_PASSWORD` | Database password | `password` |
| `BENCHMARK` | Benchmark type | `tpcc` |
| `BENCHMARK_VARIATION` | Config variation | Same as `BENCHMARK` |
| `BENCHMARK_WORK_RATE` | Workload rate | 50 |
| `BENCHMARK_SCALE_FACTOR` | Scale factor for data generation | Per-benchmark default |
| `WARMUP_TIME_SECONDS` | Warmup duration | `30` |
| `SKIP_CREATE_AND_LOAD` | Skip data loading | `false` |

### Benchmark Configuration Files

The workload configurations are located in `workload/configs/`:
- `sample_auctionmark_config.xml` - AuctionMark configuration
- `sample_tpcc_config.xml` - TPC-C configuration
- `sample_tpch_config.xml` - TPC-H configuration
- `sample_tpch5_config.xml` - TPC-H with 5 streams
- `sample_epinions_config.xml` - Epinions configuration
- `sample_seats_config.xml` - SEATS configuration
- `sample_resourcestresser_config.xml` - Resource stresser configuration

## Usage Examples

### Run TPC-C benchmark
```bash
docker run --rm \
  -e TUNING_POSTGRES_HOST=your-db-host \
  -e TUNING_POSTGRES_USER=postgres \
  -e TUNING_POSTGRES_PASSWORD=secret \
  -e BENCHMARK=tpcc \
  -e BENCHMARK_WORK_RATE=unlimited \
  -e WARMUP_TIME_SECONDS=60 \
  benchbase-workload
```

### Run TPC-H with existing data
```bash
docker run --rm \
  --env-file .env \
  -e BENCHMARK=tpch \
  -e BENCHMARK_WORK_RATE=50 \
  -e SKIP_CREATE_AND_LOAD=true \
  benchbase-workload
```

## Development

### Project Structure

```
.
├── Dockerfile              # Docker image definition
├── .env.template           # Environment variable template
├── .github/
│   └── workflows/
│       └── build-and-publish.yml  # CI/CD pipeline
└── workload/
    ├── runner.py           # Python workload runner
    ├── run_workload.sh     # Shell script wrapper
    └── configs/            # BenchBase configuration files
```

### Building Locally

```bash
# Build the image
docker build -t benchbase-workload .

# Run with custom config
docker run --rm -it \
  --env-file .env \
  benchbase-workload
```

### Customizing Workloads

To add custom benchmark configurations:

1. Create a new XML config file in `workload/configs/`
2. Set `BENCHMARK_VARIATION` to your config name (without `sample_` prefix and `.xml` suffix)
3. Rebuild the Docker image

## CI/CD

The project includes a GitHub Actions workflow that automatically builds and publishes Docker images to GitHub Container Registry (GHCR) on pushes to main branch.

The published images are available at:
```
ghcr.io/dbtuneai/benchbase-workload:latest
ghcr.io/dbtuneai/benchbase-workload:<branch-name>
ghcr.io/dbtuneai/benchbase-workload:<commit-sha>
```

## Performance Tuning

The runner includes optimized JVM settings:
- 5GB maximum heap size
- G1 garbage collector with optimized settings
- Heap dump on out-of-memory errors
- Parallel GC threads configured for performance

## Health Checks

The workload runner creates a `.done` file after the warmup period to indicate the benchmark is running and ready for measurements.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your database setup
5. Submit a pull request

## License

This project packages and extends BenchBase. Please refer to the [BenchBase license](https://github.com/cmu-db/benchbase) for licensing information.