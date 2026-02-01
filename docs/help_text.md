# SILO benchmarking CI system help

# Essentials

* To insert a benchmark job, simply force-push your commit from your
  laptop to your branch `bench_$USER` in the SILO repository on
  GitHub, where USER is your ssh username on this server
  (e.g. "alexander"). See `remote_branch_names_for_poll` in
  `~/etc/evobench.ron` for more branch configurations.
  
  Alternatively, you can do it on the command line, read the help on
  `evobench insert`.
  
  Note that jobs (same commit *and* parameters), once inserted, will
  not be re-inserted if pushed again, except when using the `--force`
  option on the command line (again, read the help on `evobench
  insert`).

* Run `evobench status` for an overview of status and paths.

* Wrappers for convenience

    - `list`: watch the job list (runs `watch evobench list` with
      color options, or if options are passed, pipes to less instead;
      `-v` and `-a` are the most likely used options.)
    - `list-path`: same as `list` but shows the parameters as paths
      (give it the `full` or `url` arguments for variants thereof)
    - `list-all`: see all ever inserted jobs (runs `evobench list-all` 
      with pager and color option; passes through given options)

* Outputs: see <https://silo-benchmarks.genspectrum.org/> or
  `~/silo-benchmark-outputs`.

* To investigate an error, see "How to investigate a job failure"
  below.

# Programs and logs

Everything goes through the `evobench` tool. Run it without arguments
(or `--help`, `-h` or `help`) to get a help text. It has a hierarchy
of sub-commands; ask for the help on each level for details on that
sub-command.

  - The daemon that runs the jobs, started via the crontab, logs to
    `~/logs/run/`.  Run `evoench-jobs run daemon logf` to follow the
    log interactively, or go visit the files in the directory via the
    shell.  You can see if the daemon is running with `evobench
    run daemon status` or in `evobench status`.
    
  - The daemon that checks the Github repository, also started via the
    crontab, logs to `~/logs/poll/`. Use `evobench poll daemon
    ..` the same way as for the run daemon above.

When you see a program with a name like `silo_02daf40559` running in
top/ps, then you know that it was started by the benchmarks------the
SILO benchmark runner renames the binaries to make sure rebuilds
happen precisely when re-using a working directory for a commit it
hasn't seen, and as a side effect this allows distinguishing those
programs from normal `silo` instances.

The `evobench` tool is built from the
`~/src/evobench/evobench-tools` directory. To install a new version,
after `git pull`, use `cargo install --locked --path .` from the root
of this directory (the `--locked` option says to use the dependencies
from the `Cargo.lock`, which are known working and partially reviewed
or otherwise somewhat checked for supply chain safety; by default it
would install the newest possible versions).

# Queues

Use `evobench list` to see the current state of the processing queues
(it also has `-a` and `-v` options, see `evobench list --help`). To
keep watching changes, just run the `list` or `list-path` wrapper
scripts as mentioned above.

The queues consist of directories containing files, one job per file,
under `~/.evobench/queues`.  If you're careful, you can move jobs
between queues by just moving the files (using the `mv` command or
similar), except you shouldn't move a file if it is currently being
executed. Use `evobench list -v` (or the alias, `list -v`) to both
see the file names for each job, and whether it is running (`R` while
the job is running or `E` while its results are statistically
evaluated).

(Possible todo: add queue handling commands?)

# How to investigate a job failure

evobench maintains a pool of working directories (clones of the
target project repository) under
`~/.evobench/working_directory_pool/` that it uses to avoid the
need to rebuild when a job for the same commit id is run again. 

When there is a failure during execution (be it build or run time) in
a particular working directory, the directory is marked with status
'error', which takes it out of active use by the benchmarking runner,
to allow for investigation of the failure. After a certain number of
days, such working directories are automatically deleted (see the
`evobench wd cleanup` entry in `crontab -l`), unless when marked
with 'examination' status, which happens as mentioned below.

Interaction with working directories is best done via the
`evobench wd` subcommand.

If there was a failure (a job ended up in the "erroneous-jobs" queue),
you can check for the reason as follows:

1. Get the working directory id (number) that the job was last
   executed in (shown by `list` or `list -a`, in the "WD" column). You
   can also see all working directories sorted by last activity via
   `evobench wd list`.

2. To see the log from the failed job, run `evobench wd log $id`.

3. To examine the working directory itself, re-run the job etc., run
   `evobench wd enter $id`. This opens a shell in the working
   directory. The working directory status is set to "examination",
   which prevents it from being auto-deleted.

4. When done, just exit the shell and answer `y` regarding the
   reversion of the dir status back to "error". If your ssh connection
   got severed and you want to tell that you're done later:
   `evobench wd unmark $id` (this just makes the directory
   eligible again for deletion by the cronjob that is running
   `evobench wd cleanup`; if you want to delete the working
   directory immediately, run `evobench wd delete $id` now, (or
   carefully delete it from the file system manually)).

# Results and datasets

The results are written to `~/silo-benchmark-outputs`

`~/www_data` (currently a symlink to `~/silo-benchmark-outputs`) is
what's shown on <https://silo-benchmarks.genspectrum.org/>

The input datasets are in `~/silo-benchmark-datasets/`. Please never
modify existing datasets, it would render existing results
incomparable [1]. Add a new subdirectory (besides `SC2open` and
`west_nile`) if you want to add a different dataset. You can refer to
it by name via the `DATASET` custom parameter in the
`custom_parameters` field in the config file (see below for where to
find the config file).

[1] other than change their format to adapt to newer project versions,
if necessary, but then make a new versioned subdirectory as mentioned
in the next paragraph

The dataset files are not directly below those directories, but in
subdirectories naming versions of the target project (SILO); either
tag names or commit ids work for that (prefer tag names for
readability). The files should be equivalent for all versions
(i.e. should not have a secondary effect on performance). You can use
symlinks to avoid copying unchanged files.

# Configuration

If you want to read or need to edit the configuration, you find it in
`~/silo-benchmark-ci/etc`. The file `evobench.ron` in this directory
is referenced by symlink from `~/.evobench.ron`, which is the location
read by `evobench`. Since this is a Git repository, please commit your
changes------they should end up on
<https://github.com/GenSpectrum/silo-benchmark-ci/> eventually.

That same repository is also independently cloned at
`/opt/silo-benchmark-ci`, but just for the
`/opt/silo-benchmark-ci/root/other-activity` file, which is configured
to be executed via sudo (hence we keep this file separate, owned by
root, for security).

# SEE ALSO

* [Evobench documentation](https://github.com/GenSpectrum/evobench/blob/master/evobench-tools/docs/overview.md)

