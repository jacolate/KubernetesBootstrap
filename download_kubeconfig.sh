#!/bin/bash

# Variables
REMOTE_SERVER=""
REMOTE_PORT=""
REMOTE_KUBECONFIG_PATH="/home/ansibleuser/.kube/config"
NEW_KUBECONFIG="/tmp/kubeconfig"
KUBECONFIG_DIR="$HOME/.kube"
KUBECONFIG_FILE="$KUBECONFIG_DIR/config"
BACKUP_FILE="$KUBECONFIG_DIR/config.backup"
OLD_IP=""
NEW_IP=""

echo "Downloading kubeconfig from the remote server..."
scp -P $REMOTE_PORT $REMOTE_SERVER:$REMOTE_KUBECONFIG_PATH $NEW_KUBECONFIG

if [ $? -ne 0 ]; then
  echo "Failed to download kubeconfig file."
  exit 1
fi

echo "Download complete."

echo "Replacing IP address in the kubeconfig file..."
sed -i "" "s/$OLD_IP/$NEW_IP/g" "$NEW_KUBECONFIG"

if [ $? -ne 0 ]; then
  echo "Failed to replace IP address."
  exit 1
fi

echo "IP address replacement complete."

echo "Backing up the existing kubeconfig file..."
cp "$KUBECONFIG_FILE" "$BACKUP_FILE"

if [ $? -ne 0 ]; then
  echo "Failed to backup existing kubeconfig file."
  exit 1
fi

echo "Backup complete."

echo "Extracting clusters, contexts, and users from the new kubeconfig..."
new_clusters=$(kubectl config view --kubeconfig="$NEW_KUBECONFIG" -o jsonpath='{.clusters[*].name}')
new_contexts=$(kubectl config view --kubeconfig="$NEW_KUBECONFIG" -o jsonpath='{.contexts[*].name}')
new_users=$(kubectl config view --kubeconfig="$NEW_KUBECONFIG" -o jsonpath='{.users[*].name}')

remove_existing_entries() {
    local names="$1"
    local type="$2"
    for name in $names; do
        echo "Removing existing $type entry: $name"
        kubectl config --kubeconfig="$KUBECONFIG_FILE" unset "$type.$name"
    done
}

echo "Removing existing clusters, contexts, and users with the same names..."
remove_existing_entries "$new_clusters" "clusters"
remove_existing_entries "$new_contexts" "contexts"
remove_existing_entries "$new_users" "users"

echo "Removal complete."

echo "Merging new kubeconfig with the existing one..."
KUBECONFIG=$KUBECONFIG_FILE:$NEW_KUBECONFIG kubectl config view --merge --flatten > "$KUBECONFIG_DIR/merged_config"

if [ $? -ne 0 ]; then
  echo "Failed to merge kubeconfigs."
  exit 1
fi

echo "Updating kubeconfig file..."
mv "$KUBECONFIG_DIR/merged_config" "$KUBECONFIG_FILE"

if [ $? -ne 0 ]; then
  echo "Failed to update kubeconfig file."
  exit 1
fi

echo "Cleaning up..."
rm "$NEW_KUBECONFIG"

if [ $? -ne 0 ]; then
  echo "Failed to clean up temporary files."
  exit 1
fi

echo "Kubeconfig has been updated and merged successfully."
