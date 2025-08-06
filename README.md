# SILO benchmarking CI system

These are the files for maintaining an
[evobench](https://github.com/GenSpectrum/evobench/) based
benchmarking runner on a server.

Using a dedicated server has the advantage that

 * the full datasets can be used (perhaps needing lots of RAM)
 * no interference from other workloads, hence better measurements

`evobench-run` has a feature (see `stop_start` attribute in
[etc/evobench-run.ron](etc/evobench-run.ron)) to temporarily shut down
other workloads while running benchmarks, thus the same server can be
used for other things at other times.

The system consists of a daemon (via `evobench-run -v run daemon`)
that watches a set of job queues and executes them at the configured
times, and regular execution of a check for new commits on configured
branches (via `evobench-run poll`, see
[bin/evobench-run-poll](bin/evobench-run-poll)).

We are currently running the system under the `evobench` user on
`gs-staging-1`.

## Installation

1. create a user account (e.g. `evobench`)
1. install evobench:

    1. install the current stable Rust toolchain in this account via [rustup](https://rustup.rs/)
    1. log out and in again (or source the shell startup files)
    1. `git clone https://github.com/GenSpectrum/evobench`
    1. `cd evobench/evobench-evaluator/; cargo install --locked --path .`

1. `cd; git clone https://github.com/GenSpectrum/silo-benchmark-ci .silo-benchmark-ci`
1. `cd; ln -s .silo-benchmark-ci/bin; ln -s .silo-benchmark-ci/etc; ln -s etc/evobench-run.ron .evobench-run.ron`
1. create `~/silo-benchmark-datasets` directory, put subdirectories with the datasets (todo: where from?)
1. Get conan:

        python3 -m venv ~/venv
        source ~/venv/bin/activate
        pip install conan==2.8.1

1. Start daemon (for now):

        cd
        screen
        nohup evobench-run -v run daemon

1. Add poller to crontab:

        mkdir ~/log
        echo $PATH
        crontab -e

    Add `PATH=...output from echo $PATH` to the top, and `* * * * *  bin/evobench-run-poll`

## More info

For the docs shown when logging into the account via ssh, see
[docs/README.md](docs/README.md)
