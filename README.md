# Disk usage checker

Run from your main PC:

```bash
./check_disk_usage.sh
./check_disk_usage.sh 85
./check_disk_usage.sh --verbose 85
```

Checks the filesystem mounted at `/` on `panda1gpu5090`, `panda3gpu5090`,
and `cs-ws43` over SSH. Sends one desktop notification listing hosts whose usage
is **90% or more** by default. Pass a threshold from 1 to 100 as a positional
argument to change it. The device name does not matter.

Normal runs produce no terminal output. Use `-v` or `--verbose` to print OK and
warning messages as well. Errors are always printed to stderr. Notifications
are sent on every run where a host reaches the threshold; below the threshold,
no notification is sent. Use `-h` or `--help` for usage.

Requires Bash, SSH, awk, and `notify-send` locally, and `df` on the remote hosts.
On Debian/Ubuntu, `notify-send` is provided by `libnotify-bin`. Run from your
logged-in graphical desktop session so notifications can reach it. Uses your
existing SSH configuration and username. SSH runs without password prompts,
so set up SSH keys (or an SSH agent) and connect to each host manually once to
accept its host key before running the script.

Edit `hosts` at the top of the script to change the machines. Individual
SSH or output errors are reported, and the remaining hosts are still checked.

Exit codes, suitable for future automation:

- `0`: All hosts are below the threshold.
- `1`: At least one host is at or above the threshold.
- `2`: Invalid arguments, a failed check, or a failed notification (takes
  precedence over warnings).

Scheduling is not configured by this script.
