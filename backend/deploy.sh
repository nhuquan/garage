#!/bin/bash

# Configuration
SERVER_IP="38.60.252.191"
SERVER_USER="daniel"
REMOTE_DIR="garage-backend"

echo "🚀 Preparing for deployment to $SERVER_IP..."

# Step 1: Create the remote directory and sync files
echo "📦 Syncing files to ~/$REMOTE_DIR..."
ssh $SERVER_USER@$SERVER_IP "mkdir -p ~/$REMOTE_DIR"

# Clean up any existing macOS metadata files on the server that might cause issues
echo "🧹 Cleaning up old metadata on server..."
ssh $SERVER_USER@$SERVER_IP "find ~/$REMOTE_DIR -name '._*' -delete 2>/dev/null"
ssh $SERVER_USER@$SERVER_IP "find ~/$REMOTE_DIR -name '.DS_Store' -delete 2>/dev/null"

# Clean up macOS metadata files locally before syncing
echo "🧹 Cleaning local metadata..."
dot_clean -m .

# Sync using tar while excluding macOS metadata and other unnecessary files
tar -cz --exclude='.git' \
        --exclude='.dart_tool' \
        --exclude='build' \
        --exclude='*/.DS_Store' \
        --exclude='*/._*' \
        . | ssh $SERVER_USER@$SERVER_IP "tar -xz -C ~/$REMOTE_DIR"

# Step 2: Run docker-compose on the server
echo "🏗️ Building and starting containers on the server..."
# Use V2 (docker compose) first to avoid V1 bugs. Add 'down' for a clean state.
ssh $SERVER_USER@$SERVER_IP "cd ~/$REMOTE_DIR && \
    (docker compose down || docker-compose down) && \
    (docker compose up -d --build || docker-compose up -d --build) && \
    (docker image prune -f)"

echo "✅ Deployment complete!"
echo "Your backend should be running at https://garage-api.livana.dev"
