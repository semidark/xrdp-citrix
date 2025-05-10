#!/bin/bash

# Parse command line arguments
NO_CACHE=""
for arg in "$@"; do
  if [ "$arg" == "--no-cache" ]; then
    NO_CACHE="--no-cache"
  fi
done

# Check if .env file exists
if [ -f .env ]; then
  # Load environment variables from .env file
  export $(cat .env | grep -v '#' | xargs)
else
  echo "Warning: .env file not found. Using default values."
fi

# Build with environment variables (with defaults if not set)
docker build \
  $NO_CACHE \
  --build-arg USERNAME=${USERNAME:-user} \
  --build-arg PASSWORD=${PASSWORD:-password} \
  -t xrdp-citrix .

echo "Build complete!" 