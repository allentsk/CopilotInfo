#!/bin/zsh

# Check if REPO_HOME is set
# Repo home is a github home directory on the local system.  This will be mounted
# in the docker home so the cmake build files can be run
if ! [[ -v GITHUB_WORKSPACE ]]; then
  echo "env variable:GITHUB_WORKSPACE is not set -- terminating"
  exit 2
fi

# -it in the execution just opens up the docker image.
# Without it it just opens, runs the entry point and finisheds
#docker run --rm -v "$REPO_HOME":/src -w /src -it ubuntu-midirouter bash
docker run --rm --mount type=bind,source="$GITHUB_WORKSPACE",target=/github/workspace \
  -w /github/workspace \
  -e GITHUB_WORKSPACE=/github/workspace \
  -it ubuntu-midirouter bash
