# SILO benchmarking CI system help

# Essentials

* Insert: simply force-push your commit from your laptop to your
  branch `bench_$USER` in the SILO repository on GitHub, where USER is
  your ssh username here (e.g. "alexander"). (Alternatively,
  `evobench-run insert $commit`.)

* Aliases

    - `list`: watch the job list (runs `watch evobench-run list` with
      color options, or if options are passed, pipes to less instead;
      `-v` and `-a` are the most likely used options.)
    - `list-all`: see all ever inserted jobs (runs `evobench-run
      list-all` with pager and color option; passes through given
      options)

* Outputs: see <https://silo-benchmarks.genspectrum.org/> or `~/silo-benchmark-outputs`.

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
    running `source ~/venv/bin/activate`, or SILO won't build!)  `tail
    -f ~/log/daemon.log` will show you interactively what's going on.

When you see a program with a name like `silo_02daf40559` running in
top/ps/whatever, then you know that it was started by the
benchmarks------the SILO benchmark runner renames the binaries to make
sure rebuilds happen precisely when re-using a working directory for
a commit it hasn't seen, and as a side effect this allows
distinguishing those programs from normal `silo` instances.

The `evobench-run` tool is built from the
`~/evobench/evobench-evaluator` directory. To install a new version,
after `git pull`, use `cargo install --locked --path .` from the root
of this directory (the `--locked` option says to use the dependencies
from the `Cargo.lock`, which are known working and partially reviewed
or otherwise somewhat checked for supply chain safety; by default it
would install the newest possible versions).

# Queues

Use `evobench-run list` or `evobench-run list -v` to see the current
state of the processing queues. You could run `watch evobench-run
list` (or `watch --color evobench-run list --color=always` to see
formatting) to watch queue changes on the side.

The queues consist of directories containing files, one job per file,
under `~/.evobench-run/queues`.  If you're careful, you can move jobs
between queues by just moving the files (using the `mv` command or
similar), except you shouldn't move the file if it is currently locked
(which means, being executed). Use `evobench-run list -v` to both see
the file names for each job, and whether it is locked. (A subcommand
to do such moves safely could be added if desired.)

# Working directories

evobench-run maintains a pool of working directories (clones of the
target project repository) under
`~/.evobench-run/working_directory_pool/` that it uses to avoid the
need to rebuild when a job for the same commit id is run again. When
there is a failure (be it build or run time) in a particular working
directory, it is set aside to allow investigation. Also saved in this
directory are log files of the outputs (stderr lines as "E" and stdout
lines as "O") of the process under benchmarking.

So if there was a failure (a job ended up in the "erroneous-jobs"
queue) that you want to investigate:

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
`~/etc/`, which is a symlink to `/opt/silo-benchmark-ci/etc`. The file
`evobench-run.ron` in this directory is referenced by symlink from
`~/.evobench-run.ron`, which is the location read by
`evobench-run`. This location is owned by root, so use sudo from your
own account. Since this is a Git repository, please commit your
changes------they should end up on
<https://github.com/GenSpectrum/silo-benchmark-ci/> eventually.
