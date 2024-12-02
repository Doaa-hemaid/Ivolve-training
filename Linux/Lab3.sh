#!/bin/bash

# Loop through the range 0-255
for x in {0..255}; do
  # Ping the server with a single packet and 1-second timeout
  if ping -c 1 -W 1 192.168.225.$x &> /dev/null; then
    echo "Server 192.168.225.$x is up and running"
  else
    echo "Server 192.168.225.$x is unreachable"
  fi
done
