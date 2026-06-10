#!/bin/bash

set -e

GENERATOR_IMAGE="hw3-generator"
REPORTER_IMAGE="hw3-reporter"
DATA_DIR="$(pwd)/data"

case "$1" in
  build_generator)
    docker build -t "$GENERATOR_IMAGE" ./generator
    ;;

  run_generator)
    mkdir -p data
    docker run --rm -v "$DATA_DIR:/data" "$GENERATOR_IMAGE"
    echo "Generated: data/data.csv"
    ;;

  create_local_data)
    mkdir -p local_data
    python3 generator/generate.py local_data
    echo "Generated: local_data/data.csv"
    ;;

  build_reporter)
    docker build -t "$REPORTER_IMAGE" ./reporter
    ;;

  run_reporter)
    docker run --rm -v "$DATA_DIR:/data" "$REPORTER_IMAGE"
    echo "Generated: data/report.html"
    ;;

  structure)
    find . -not -path '*/.git*' -not -name '.git' | sort
    ;;

  clear_data)
    rm -f data/*.csv data/*.html
    echo "Cleared data/"
    ;;

  inside_generator)
    docker run --rm -v "$DATA_DIR:/data" --entrypoint sh "$GENERATOR_IMAGE" -c "ls /data"
    ;;

  inside_reporter)
    docker run --rm -v "$DATA_DIR:/data" --entrypoint sh "$REPORTER_IMAGE" -c "ls /data"
    ;;

  report_server)
    docker run --rm -d -p 8080:80 -v "$DATA_DIR:/usr/share/nginx/html:ro" nginx:alpine
    echo "Server started at http://localhost:8080/report.html"
    ;;

  *)
    echo "Usage: $0 {build_generator|run_generator|create_local_data|build_reporter|run_reporter|structure|clear_data|inside_generator|inside_reporter|report_server}"
    exit 1
    ;;
esac
