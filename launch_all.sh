#!/bin/bash

# Directory containing the account configuration files
ACCOUNTS_DIR="./accounts"

# Check if the accounts directory exists
if [ ! -d "$ACCOUNTS_DIR" ]; then
  echo "Accounts directory not found: $ACCOUNTS_DIR"
  exit 1
fi

# Iterate over each .sh file in the accounts directory
for account_file in "$ACCOUNTS_DIR"/*.sh;
do
  # Extract the account name from the filename
  ACCOUNT_NAME=$(basename "$account_file" .sh)

  echo "Starting account: $ACCOUNT_NAME"

  # Run the launch.sh script with the account name
  ./launch.sh "$ACCOUNT_NAME"

done

echo "All accounts have been started."