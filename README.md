# SILO benchmarking CI system

These are the files for maintaining an
[evobench](https://github.com/GenSpectrum/evobench/) based
benchmarking runner on a server.

Using a dedicated server has the advantage that

 * the full datasets can be used (perhaps needing lots of RAM)
 * no interference from other workloads, hence better measurements

`evobench-run` has a feature (see `stop_start` in
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

TODO

