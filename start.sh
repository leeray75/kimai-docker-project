#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Output the loaded environment variables
echo "Loaded environment variables:"
echo "--------------------------------"
echo "MYSQL_CONTAINER: '$MYSQL_CONTAINER'"
echo "MYSQL_DATABASE: '$MYSQL_DATABASE'"
echo "MYSQL_USER: '$MYSQL_USER'"
echo "MYSQL_PASSWORD: '$MYSQL_PASSWORD'"
echo "MYSQL_ROOT_PASSWORD: '$MYSQL_ROOT_PASSWORD'"
echo "MYSQL_PORT: '$MYSQL_PORT'"
echo "KIMAI_CONTAINER: '$KIMAI_CONTAINER'"
echo "KIMAI_PORT: '$KIMAI_PORT'"
echo "ADMIN_EMAIL: '$ADMIN_EMAIL'"
echo "ADMIN_PASSWORD: '$ADMIN_PASSWORD'"
echo "--------------------------------"
echo ""

# Remove spaces and check if variables are correctly assigned
MYSQL_PORT=$(echo "$MYSQL_PORT" | tr -d '[:space:]')
KIMAI_PORT=$(echo "$KIMAI_PORT" | tr -d '[:space:]')

# Define the Docker network
NETWORK_NAME="kimai-network"

# Function to stop and remove an existing container
remove_container_if_exists() {
    local container_name=$1
    if [ "$(docker ps -aq -f name=$container_name)" ]; then
        echo "Stopping container: $container_name"
        docker stop "$container_name"
        echo "Removing container: $container_name"
        docker rm -f "$container_name"
    fi
}

# Function to check if an admin user already exists
check_user_exists() {
    local email=$1
    echo "Checking if user with email $email exists..."
    docker exec -ti "$KIMAI_CONTAINER" /opt/kimai/bin/console kimai:user:list | grep -q "$email"
    return $?
}

# Remove existing MySQL container if it exists
remove_container_if_exists "$MYSQL_CONTAINER"

# Create a Docker network if it doesn't exist
docker network inspect "$NETWORK_NAME" >/dev/null 2>&1 || docker network create "$NETWORK_NAME"

# Start MySQL container with volume for persistent data
echo "Starting MySQL container on port $MYSQL_PORT..."
docker run --name "$MYSQL_CONTAINER" \
    --network "$NETWORK_NAME" \
    -e MYSQL_DATABASE="$MYSQL_DATABASE" \
    -e MYSQL_USER="$MYSQL_USER" \
    -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    -p "$MYSQL_PORT:3306" \
    -v mysql-data:/var/lib/mysql \
    -d mysql:8.0

# Check if MySQL container started successfully
if [ $? -ne 0 ]; then
    echo "Error starting MySQL container"
    exit 1
fi

# Wait for MySQL to initialize
echo "Waiting for MySQL to initialize..."
sleep 20

# Remove existing Kimai container if it exists
remove_container_if_exists "$KIMAI_CONTAINER"

# Start Kimai container with volume for persistent data and updated DATABASE_URL
echo "Starting Kimai container on port $KIMAI_PORT..."
docker run --name "$KIMAI_CONTAINER" -d \
    --network "$NETWORK_NAME" \
    -p "$KIMAI_PORT:8001" \
    -e DATABASE_URL="mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_CONTAINER:3306/$MYSQL_DATABASE?charset=utf8mb4&serverVersion=8.0.0" \
    -v kimai-data:/opt/kimai/var \
    kimai/kimai2:apache

# Check if Kimai container started successfully
if [ $? -ne 0 ]; then
    echo "Error starting Kimai container"
    exit 1
fi

# Wait for Kimai to initialize
echo "Waiting for Kimai to initialize..."
sleep 10

# Create admin user with predefined password from .env file if it doesn't exist
echo "Creating admin user..."
if check_user_exists "$ADMIN_EMAIL"; then
    echo "Admin user with email '$ADMIN_EMAIL' already exists."
else
    docker exec -ti "$KIMAI_CONTAINER" \
        /opt/kimai/bin/console kimai:user:create admin "$ADMIN_EMAIL" ROLE_SUPER_ADMIN "$ADMIN_PASSWORD"
    
    if [ $? -eq 0 ]; then
        echo "Admin user created successfully!"
    else
        echo "Failed to create admin user."
        exit 1
    fi
fi

echo "Kimai is now running at http://localhost:$KIMAI_PORT"
echo "Press [CTRL+C] to stop."

# Trap to stop the containers on exit (CTRL+C)
trap "echo Stopping containers...; docker stop $MYSQL_CONTAINER $KIMAI_CONTAINER; docker network rm $NETWORK_NAME; exit" SIGINT

# Keep the script running to prevent Docker containers from stopping
while true; do
    sleep 1
done
