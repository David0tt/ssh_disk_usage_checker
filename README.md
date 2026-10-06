# Disk usage checker

Notifies you when / usage on tracked systems reaches THRESHOLD percent

```bash
./check_disk_usage.sh [-v|--verbose] [--hosts HOST1,HOST2,...] [THRESHOLD]
```

Checks the filesystem mounted at `/` over SSH. Sends a desktop notification listing hosts whose usage reaches or exceeds the threshold (default: 90%). Use `-v` or `--verbose` to also get terminal output.

Hosts can be specified with `--hosts` followed by a comma-separated list without
spaces. SSH access without login to all hosts needs to be ensured. 
