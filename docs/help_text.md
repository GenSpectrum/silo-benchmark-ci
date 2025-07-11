# SILO benchmarking CI system help

# Programs and logs

Everything goes through the `evobench-run` tool. Run it without
arguments (or `--help`, `-h` or `help`) to get a help text.

  - You will primarily use the `list`, `list-all`, and `insert`
    subcommands.
  
  - The crontab runs `~/bin/evobench-run-poll`, with a log in
    `~/log/evobench-poll.log`
  
  - The daemon that runs the jobs, running as `evobench-run -v run
    daemon`, currently in a screen session, logs to
    `~/log/daemon.log`. (This command must be started after first
    running `source ~/venv/bin/activate`, or SILO won't build!)

When you see a program with a name like `silo_02daf40559` running in
top/ps/whatever, then you know that it was started by the
benchmarks------the SILO benchmark runner renames the binaries to make
sure rebuilds happen precisely when re-using a working directory for
a commit it hasn't seen, and as a side effect this allows
distinguishing those programs from normal `silo` instances.

The `evobench-run` tool is built from the
`~/evobench/evobench-evaluator` directory, in case you need to
install a newer version.

# Queues and working directories

Use `evobench-run list` or `evobench-run list -v` to see the current
state of the processing queues. If you need to investigate some
failures:

      cd ~/.evobench-run/working_directory_pool/
      ls -lrt

Then find the right `*.error_at_*` file, and for the same timestamp,
the `*.output_of_benchmarking_command_at_*` file. `cd N.*/` where N
is the number of the working directory that had the error. If you
need to work with SILO inside, rename the directory back to just N
first. Renaming back to N is also giving it back to the pool, so it
can be re-used for benchmarking (but it will currently only be picked up when
the daemon is restarted (potential TODO for improvements)).

# Results and datasets

The results are written to `~/silo-benchmark-outputs`

`~/www_data` (currently a symlink to `~/silo-benchmark-outputs`) is
what's shown on <https://silo-benchmarks.genspectrum.org/>

The input datasets are in `~/silo-benchmark-datasets/`. Please never
modify existing datasets, it would invalidate existing results. Add
a new subdirectory (besides `full`) if you want to add a different
dataset. You can refer to it by name via the
`BENCHMARK_DATASET_NAME` custom parameter in the
`custom_parameters_set` field in the config file, see below for
where to find that.

# Configuration

If you want to read or need to edit the configuration, you find it in
`~/etc/`. The file `evobench-run.ron` there is referenced by symlink
from `~/.evobench-run.ron`, which is the location read by
`evobench-run`. `~/etc/` is a Git repository, commit your changes!

