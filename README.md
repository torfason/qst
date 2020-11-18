This package provides functions for quickly writing (and reading back) a `data.frame` to file in `sqlite` format. The name stands for *Store Tables using SQLite*, or alternatively for *Quick Store Tables* (either way, it could be pronounced as *Quest*). For `data.frames` containing the supported data types it is intended to work as a drop-in replacement for the `write_*()` and `read_*()` functions provided by packages such as `fst`, `feather`, `qs`, and `readr` packages (as well as the `writeRDS()` and `readRDS()` functions). 

The core functions are `read_qst()` and `write_qst()`, which read/write a `data.frame` from/to a SQLite database. The database contains a single table named `data`, which contains the data from the `data.frame`.

The package wraps the functionality of `RSQLite` and `dbplyr`, which do the heavy lifting. The resulting file is reasonably small and the read/write process for a complete file is reasonably fast, although no claims are made of superiority to the above packages that focus on these issues.

This packages shines in the ability to quickly and easily switch from loading a complete `data.frame` to using `dbplyr`/`SQLite` to subset data on disk before loading it into memory. This is done simply by setting the `lazy` parameter of `read_qst()` to `TRUE`:

```R
write_qst(dat_org, "dat.qst")         # A reasonably large data set
dat_full <- read_qst("dat.qst")       # Reasonably quick
dat <- read_qst("dat.qst", lazy=TRUE) # Near instanteous
dat                                   # Prints out nicely using dbplyr
dat %>% filter(state=="AZ")           # Filtered from disk using SQLite
```

Filtering from disk (as shown in the last line) is reasonably fast (typically much faster than loading the whole data set before then filtering in memory), even without indexes. With indexes, which can be created on write with the `indexes` and `unique_indexes` arguments to `write_qst()`, it becomes even faster.

### Road map

The following features are planned in future releases:

* Support dates
* Support factors
* Support logical data types
* Support variable labels
* Support value labels

If you are using `qst` and would like a specific feature to be implemented, either from the road map or another feature, the simplest way to request it is by opening an issue.

