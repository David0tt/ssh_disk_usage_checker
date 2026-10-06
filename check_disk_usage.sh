#!/usr/bin/env bash

# Check the filesystem mounted at / on each host, using existing SSH settings.
hosts=(panda1gpu5090 panda3gpu5090 cs-ws43)
threshold=90
threshold_given=false
verbose=false
status=0
warnings=()

usage() {
    printf 'Usage: %s [-v|--verbose] [THRESHOLD]\n' "${0##*/}"
    printf 'Notify when / usage reaches THRESHOLD percent (1-100, default: 90).\n'
}

for arg in "$@"; do
    case "$arg" in
        -v|--verbose) verbose=true ;;
        -h|--help) usage; exit 0 ;;
        *)
            if $threshold_given || [[ ! $arg =~ ^[0-9]{1,3}$ ]] ||
                (( 10#$arg < 1 || 10#$arg > 100 )); then
                printf 'ERROR: expected one threshold between 1 and 100; got "%s"\n' "$arg" >&2
                usage >&2
                exit 2
            fi
            threshold=$((10#$arg))
            threshold_given=true
            ;;
    esac
done

for host in "${hosts[@]}"; do
    if ! output=$(ssh -o BatchMode=yes -o ConnectTimeout=10 \
        -o ServerAliveInterval=10 -o ServerAliveCountMax=2 \
        "$host" 'LC_ALL=C df -P /'); then
        printf 'ERROR: %s: could not check disk usage over SSH\n' "$host" >&2
        status=2
        continue
    fi

    usage=$(awk 'NR == 2 { print $5 }' <<< "$output")
    if [[ ! $usage =~ ^[0-9]+%$ ]]; then
        printf 'ERROR: %s: unexpected df output\n' "$host" >&2
        status=2
        continue
    fi

    percent=${usage%%%}
    if (( 10#$percent >= threshold )); then
        warnings+=("$host: / is $usage used")
        if $verbose; then
            printf 'WARNING: %s: / is %s used (threshold: %s%%)\n' \
                "$host" "$usage" "$threshold"
        fi
        if (( status == 0 )); then
            status=1
        fi
    elif $verbose; then
        printf 'OK: %s: / is %s used\n' "$host" "$usage"
    fi
done

if (( ${#warnings[@]} > 0 )); then
    if ! command -v notify-send >/dev/null 2>&1; then
        printf 'ERROR: notify-send is required for desktop notifications\n' >&2
        status=2
    elif ! notify-send --urgency=critical "Disk usage warning (threshold: $threshold%)" \
        "$(printf '%s\n' "${warnings[@]}")"; then
        printf 'ERROR: could not send desktop notification\n' >&2
        status=2
    fi
fi

exit "$status"
