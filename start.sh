#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Start MySQL container with volume for persistent data
echo "Starting MySQL container..."
docker run --name $MYSQL_CONTAINER \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -e MYSQL_USER=$MYSQL_USER \
    -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -p $MYSQL_PORT:3306 \
    -v mysql-data:/var/lib/mysql \
    -d mysql:8.0

# Wait for MySQL to initialize
echo "Waiting for MySQL to initialize..."
sleep 20

# Start Kimai container with volume for persistent data (if necessary)
echo "Starting Kimai container..."
docker run --name $KIMAI_CONTAINER -d \
    -p $KIMAI_PORT:8001 \
    -e DATABASE_URL="mysql://$MYSQL_USER:$MYSQL_PASSWORD@host.docker.internal:$MYSQL_PORT/$MYSQL_DATABASE?charset=utf8mb4&serverVersion=8.0.0" \
    -v kimai-data:/opt/kimai/var \
    kimai/kimai2:apache

# Wait for Kimai to initialize
echo "Waiting for Kimai to initialize..."
sleep 10

# Add an admin user if not already present
echo "Creating admin user..."
docker exec -ti $KIMAI_CONTAINER \
    /opt/kimai/bin/console kimai:user:create admin $ADMIN_EMAIL ROLE_SUPER_ADMIN

echo "Kimai is now running at http://localhost:$KIMAI_PORT"
echo "Press [CTRL+C] to stop."

# Keep the script running to prevent Docker containers from stopping
while true; do
    sleep 1
done
