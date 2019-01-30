# RepoSyncJob
This is a pair of .bat files meant to be run as a scheduled task to keep local repo clones in sync with what's in the master.

The files are written for use on nanovak-home, but are easily configurable for another system (just update the paths).

## RunSync.bat
This is the file that you run via Windows' task scheduler. It generates a current date/time variable and then kicks off GitPulls.bat

## GitPulls.bat
1. Does a git pull for the specified repo
2. Cleans up log files older than X days