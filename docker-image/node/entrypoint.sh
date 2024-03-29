#!/bin/sh
# vim:sw=4:ts=4:et

set -e

exec 3>&1

if /usr/bin/find "/entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo >&3 "$0: /entrypoint.d/ is not empty, will attempt to perform configuration"

    echo >&3 "$0: Looking for shell scripts in /entrypoint.d/"
    find "/entrypoint.d/" -follow -type f -print | sort -n | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo >&3 "$0: Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo >&3 "$0: Ignoring $f, not executable";
                fi
                ;;
            *) echo >&3 "$0: Ignoring $f";;
        esac
    done

    echo >&3 "$0: Configuration complete; ready for start up"
else
    echo >&3 "$0: No files found in /entrypoint.d/, skipping configuration"
fi

if [ ! -f "/mnt/process.sh" ]; then
  echo "File /mnt/process.sh not exits!"
  tail -f /dev/null
fi

chmod +x /mnt/process.sh

/mnt/process.sh
