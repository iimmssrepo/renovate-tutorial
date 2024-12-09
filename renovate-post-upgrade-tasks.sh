#!/bin/bash

# Update the os_upgrade_date label with the current date in YYYYMMDD format
sed -i 's/os_upgrade_date=[0-9]*/os_upgrade_date=$(date +%Y%m%d)/' Dockerfile

echo "Renovate post upgrade tasks executed successfully."
