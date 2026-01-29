# SILO benchmarking CI system

These are the files for maintaining an
[evobench](https://github.com/GenSpectrum/evobench/) based
benchmarking runner on a server.

Using a dedicated server has the advantage that

 * the full datasets can be used (perhaps needing lots of RAM)
 * no interference from other workloads, hence better measurements

`evobench` has a feature (see `stop_start` attribute in
[etc/evobench.ron](etc/evobench.ron)) to temporarily shut down
other workloads while running benchmarks, thus the same server can be
used for other things at other times.

The system consists of a daemon (via `evobench -v run daemon`)
that watches a set of job queues and executes them at the configured
times, and regular execution of a check for new commits on configured
branches (via `evobench poll`, see
[bin/evobench-poll](bin/evobench-poll)).

We are currently running the system under the `evobench` user on
`gs-staging-1`.

## Installation

1. Create a user account (e.g. `evobench`)
    
1. Install a recent stable Rust toolchain in this account via [rustup](https://rustup.rs/)

1. Install evobench:

    1. log out and in again (or source the shell startup files) to get Rust in the PATH
    1. `git clone https://github.com/GenSpectrum/evobench`
    1. `cd evobench/evobench-tools/; cargo install --locked --path .`

1. `cd; git clone https://github.com/GenSpectrum/silo-benchmark-ci .silo-benchmark-ci`

1. `cd; ln -s .silo-benchmark-ci/bin; ln -s .silo-benchmark-ci/etc; ln -s etc/evobench.ron .evobench.ron`

1. create `~/silo-benchmark-datasets` directory, put subdirectories with the datasets (todo: where from?)

1. Get conan:

        python3 -m venv ~/venv
        source ~/venv/bin/activate
        pip install conan==2.8.1

1. Start daemon:

        evobench run daemon start

1. Install crontab:

        crontab ~/.silo-benchmark-ci/crontab

## More info

For the docs shown when logging into the account via ssh, see
[docs/README.md](docs/README.md)
