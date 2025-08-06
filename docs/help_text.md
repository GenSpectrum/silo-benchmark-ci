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
    - `list-all`: see all ever inserted jobs (runs `evobench-run list-all` 
      with pager and color option; passes through given options)

* Outputs: see <https://silo-benchmarks.genspectrum.org/> or `~/silo-benchmark-outputs`.

* To investigate an error, see "How to investigate a job failure" below

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

Use `evobench-run list` to see the current state of the processing
queues (it also has `-a` and `-v` options, see `evobench-run list
--help`). To keep watching changes, just run the `list` wrapper
script.

The queues consist of directories containing files, one job per file,
under `~/.evobench-run/queues`.  If you're careful, you can move jobs
between queues by just moving the files (using the `mv` command or
similar), except you shouldn't move the file if it is currently being
executed. Use `evobench-run list -v` to both see the file names for
each job, and whether it is running (`R`).

(Possible todo: add convenience commands?)

# Working directories

evobench-run maintains a pool of working directories (clones of the
target project repository) under
`~/.evobench-run/working_directory_pool/` that it uses to avoid the
need to rebuild when a job for the same commit id is run again. 

When there is a failure during execution (be it build or run time) in
a particular working directory, the directory is taken out of active
use by the benchmarking runner to allow investigation. The marking is
done by storing `status: Error` in the `$n.status` file for the
directory in question; the status file is also marked as executable as
a hack to make it easy to see which directories are in error status
via ls (`ls -lrt ~/.evobench-run/working_directory_pool/`). The pool
directory also contains a `current` symlink that is changed to the
working directory whenever a job is run in it (it is left around after
the job is finished).

For each job run, a file `$n.output_of_benchmarking_command_at_...` is
created, that contains the parameters used to run the job, and then
its output (stderr lines as "E" and stdout lines as "O"). And for each
job that resulted in an error, additionally a file `$n.error_at_...`
is created that contains the error (if the error was issued by the
target project (SILO), then it's easier to see the message in the
`$n.output_of...` file, though).

## How to investigate a job failure

So if there was a failure (a job ended up in the "erroneous-jobs"
queue), you can check for the reason this way:

1. Get the working directory number that it was last executed in
   (shown by `list`, in the "WD" column).
   
2. Look at the errror and/or output of the command:

        cd ~/.evobench-run/working_directory_pool/`, `
        ls -lrt
        # pick the last $n.error_at... or $n.output_of.. file
        less ...

3. If you need to investigate the working directory, just `cd $n` and
   work with it; remember, it is taken out of rotation when there was
   an error, so your work will not be interrupted.

4. When done, just `rm -rf $n` (todo: easy way to give dir back into rotation?)

# Results and datasets

The results are written to `~/silo-benchmark-outputs`

`~/www_data` (currently a symlink to `~/silo-benchmark-outputs`) is
what's shown on <https://silo-benchmarks.genspectrum.org/>

The input datasets are in `~/silo-benchmark-datasets/`. Please never
modify existing datasets, it would invalidate existing results. Add
a new subdirectory (besides `SC2open` and `west_nile`) if you want to add a different
dataset. You can refer to it by name via the
`BENCHMARK_DATASET_NAME` custom parameter in the
`custom_parameters_set` field in the config file, see below for
where to find that.

# Configuration

If you want to read or need to edit the configuration, you find it in
`~/etc/`, which is a symlink to `~/.silo-benchmark-ci/etc`. The file
`evobench-run.ron` in this directory is referenced by symlink from
`~/.evobench-run.ron`, which is the location read by
`evobench-run`. Since this is a Git repository, please commit your
changes------they should end up on
<https://github.com/GenSpectrum/silo-benchmark-ci/> eventually.

That same repository is also independently cloned at
`/opt/silo-benchmark-ci`, but just for the
`/opt/silo-benchmark-ci/root/other-activity` file, which is configured
to be executed via sudo (hence we keep this file separate, owned by
root, for security).

# SEE ALSO

* [Evobench documentation](https://github.com/GenSpectrum/evobench/blob/master/evobench-evaluator/docs/overview.md)

