#!/bin/bash

# Test the env file to make sure everything is set up properly

# Source the .env file to set the variables
env="../.env"
if [ ! -f "../.env" ]; then
  echo "No .env file found in $(realpath ..)"
  exit 1
fi

source $env || { echo "Error: .env file should only have valid key=value pairs and nothing else"; exit 1; }

# Check if each env variable is set correctly

echo "$(readlink -f "$env")"
echo "Testing..."

# Check dataPath
if [ -z "$dataPath" ] || [ ! -d "$dataPath" ]; then
  echo "  Error: $dataPath is empty or does not exist"
  exit 1
fi
echo "  dataPath=${dataPath} passed."

# Check langAnalyzer
if [ ! -n "${langAnalyzer}" ]; then
  echo "  Error: lang analyzer not set"
  exit 1
fi
echo "  langAnalyzer=${langAnalyzer} passed."

# Check ambarApiFullAddress
if [ ! -n $ambarApiFullAddress ]; then
  echo "  Error: ambarApiFullAddress not set"
  exit 1
fi
echo "  ambarApiFullAddress=${ambarApiFullAddress} passed."

# Check pathToCrawl
if [ -z "$pathToCrawl" ] || [ ! -d "$pathToCrawl" ]; then
  echo "  Error: $pathToCrawl is empty or does not exist"
  exit 1
fi
echo "  pathToCrawl=${pathToCrawl} passed."

# Check localAddress
if [ ! -n $localAddress ]; then
  echo "  Error: $localAddress not set."
  exit 1
fi
echo "  localAddress=${localAddress} passed."

# Check ambarHostAddress
if [ ! -n $ambarHostAddress ]; then
  echo "  Error: $ambarHostAddress is not set."
  exit 1
fi
echo "  ambarHostAddress=${ambarHostAddress} passed."

# Check defaultProtocol
if [[ "$defaultProtocol" != "http" && "$defaultProtocol" != "https" ]]; then
    echo "  Error: $defaultProtocol is invalid. Needs to be http or https"
fi

echo "  defaultProtocol=${defaultProtocol} passed."

echo -e "\n All checks passed!"