# Disk usage checker

A minimal script to notify you when disk usage on tracked systems goes over a specified threshold percentage. 

```bash
./check_disk_usage.sh [-v|--verbose] [--hosts HOST1,HOST2,...] [THRESHOLD]
```

Checks the filesystem mounted at `/` over SSH. Sends a desktop notification listing hosts whose usage reaches or exceeds the threshold (default: 90%). Use `-v` or `--verbose` to also get terminal output.

Hosts can be specified with `--hosts` followed by a comma-separated list without
spaces. SSH access without login to all hosts needs to be ensured. 

## Automation with cron

On the pc which should automatically check, run: 

    crontab -e

Add this single line to check the specified hosts every 30 minutes: 

```
*/30 * * * * XDG_RUNTIME_DIR=/run/user/$(id -u) DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus /home/ott/Nextcloud/ssh_disk_usage_checker/check_disk_usage.sh 90 --hosts panda1gpu5090,panda3gpu5090,cs-ws43 >> /home/ott/Nextcloud/ssh_disk_usage_checker/disk_usage_checker.log 2>&1
```

Modify the directories for the correct location of this repository. 