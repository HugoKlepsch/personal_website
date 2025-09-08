#!/usr/bin/env bash

# Build the hugo site. Invoke hugo using a docker container to avoid version conflicts.
docker run --rm -it -v $(pwd)/hugo-site:/src -w /src --user $(id -u) hugomods/hugo:std-base-non-root-0.149.1 hugo