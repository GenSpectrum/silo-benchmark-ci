# SILO benchmarking CI system help

- Everything goes through the `evobench-run` tool. Run it without
  arguments to get a help text. 
  
    - You will primarily use the `list`, `list-all`, and `insert`
      subcommands.
    
    - The crontab runs `~/bin/evobench-run-poll`, with a log in
      `~/log/evobench-poll.log`
    
    - `evobench-run -v run daemon` is currently run in a screen
      session, will be changed to a proper daemon. (This command must
      be started after first running `source ~/venv/bin/activate`, or
      SILO won't build!)

- Use `evobench-run list` or `evobench-run list -v` to see the current
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

- The results are written to `~/silo-benchmark-outputs`

- `~/www_data` (currently a symlink to `~/silo-benchmark-outputs`) is
  what's shown on https://https://silo-benchmarks.genspectrum.org/

- The input datasets are in `~/silo-benchmark-datasets/`. Please never
  modify existing datasets, it would invalidate existing results. Add
  a new subdirectory (besides `full`) if you want to add a different
  dataset. You can refer to it by name via the
  `BENCHMARK_DATASET_NAME` custom parameter in the
  `custom_parameters_set` field in the config file, see below for
  where to find that.

- The `evobench-run` tool is built from the
  `~/evobench/evobench-evaluator` directory, in case you need to
  install a newer version.

- If you want to read or need to edit the configuration, you find it
  in `~/etc/` --- the file `evobench-run.ron` is referenced by symlink
  from `~/.evobench-run.ron`, which is the location that the
  `evobench-run` tool visits. `~/etc/` is a Git repository, commit
  your changes!

(Press `q` to exit the viewer.)
