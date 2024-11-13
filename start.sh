#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Function to stop and remove containers if they are already running
cleanup() {
    echo "Stopping existing containers..."
    docker stop $MYSQL_CONTAINER $KIMAI_CONTAINER 2>/dev/null
    docker rm $MYSQL_CONTAINER $KIMAI_CONTAINER 2>/dev/null
}

# Start MySQL container
echo "Starting MySQL container..."
docker run --rm --name $MYSQL_CONTAINER \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -e MYSQL_USER=$MYSQL_USER \
    -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -p $MYSQL_PORT:3306 -d mysql:8.0

# Wait for MySQL to initialize
echo "Waiting for MySQL to initialize..."
sleep 20

# Start Kimai container
echo "Starting Kimai container..."
docker run --rm --name $KIMAI_CONTAINER -d \
    -p $KIMAI_PORT:8001 \
    -e DATABASE_URL="mysql://$MYSQL_USER:$MYSQL_PASSWORD@host.docker.internal:$MYSQL_PORT/$MYSQL_DATABASE?charset=utf8mb4&serverVersion=8.0.0" \
    kimai/kimai2:apache

# Wait for Kimai to be ready
echo "Waiting for Kimai to initialize..."
sleep 10

# Add an admin user if not already present
echo "Creating admin user..."
docker exec -ti $KIMAI_CONTAINER \
    /opt/kimai/bin/console kimai:user:create admin $ADMIN_EMAIL ROLE_SUPER_ADMIN

echo "Kimai is now running at http://localhost:$KIMAI_PORT"
echo "Press [CTRL+C] to stop."

# Trap to cleanup on exit
trap cleanup EXIT

# Keep the script running to prevent Docker containers from stopping
while true; do
    sleep 1
done
