#!/bin/bash

#
# make.sh <clone|setup|run-frontend|run-backend|run-scan-worker|run-state-worker|run-plugin-worker>
#
# This script is really just for development only. It makes it easier to
# checkout the depend projects and to set them up in a virtualenv.
#
PROJECTS="backend frontend"

if [ "$(id -u)" == "0" ]; then
    echo "abort: cannot run as root."
    exit 1
fi

if [ ! `which virtualenv` ]; then
    echo "abort: no virtualenv found"
fi

if [ ! `which python2.7` ]; then
    echo "abort: no python2.7 found"
fi

if [ ! -z "$VIRTUAL_ENV" ]; then
    echo "abort: cannot run from an existing virtual environment"
    exit 1
fi

if [ -z "$2" ]; then
    ROOT="."
else
    ROOT="$2"
fi

case $1 in
    clone)
        for project in $PROJECTS; do
            if [ ! -d "minion-$project" ]; then
                git clone --recursive "https://github.com/mozilla/minion-$project" "$ROOT/minion-$project" || exit 1
            fi
        done
        ;;
    develop)
        # Create our virtualenv
        if [ ! -d "env" ]; then
                virtualenv -p python2.7 --no-site-packages "$ROOT/env" || exit 1
        fi
        # Activate our virtualenv
        source env/bin/activate
        for project in $PROJECTS; do
            if [ -x "minion-$project/setup.sh" ]; then
				(cd "$ROOT/minion-$project"; "./setup.sh" develop) || exit 1
            fi
        done
        ;;
    install)
        for project in $PROJECTS; do
            (cd "$ROOT/minion-$project"; "sudo" "python" "setup.py" "install") || exit 1
        done
        ;;
    run-backend)
        source env/bin/activate
        minion-backend/scripts/minion-backend-api -d -r
        ;;
    run-frontend)
        source env/bin/activate
        minion-frontend/scripts/minion-frontend -d -r
        ;;
    run-scan-worker)
        source env/bin/activate
        minion-backend/scripts/minion-scan-worker
        ;;
    run-state-worker)
        source env/bin/activate
        minion-backend/scripts/minion-state-worker
        ;;
    run-plugin-worker)
        source env/bin/activate
        minion-backend/scripts/minion-plugin-worker
        ;;
    *)
        echo "Usage : $0 <clone|install|develop|run-backend|run-frontend|run-plugin-worker|run-scan-worker|run-state-worker>"
        ;;
esac
