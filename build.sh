#!/bin/bash

# Check if .env file exists
if [ -f .env ]; then
  # Load environment variables from .env file
  export $(cat .env | grep -v '#' | xargs)
else
  echo "Warning: .env file not found. Using default values."
fi

# Build with environment variables (with defaults if not set)
docker build \
  --build-arg USERNAME=${USERNAME:-user} \
  --build-arg PASSWORD=${PASSWORD:-password} \
  -t xrdp-citrix .

echo "Build complete!" 