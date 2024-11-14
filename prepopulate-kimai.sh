#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
  echo "Loading environment variables from .env file..."
  export $(grep -v '^#' .env | xargs)
else
  echo "[ERROR] .env file not found!"
  exit 1
fi

# Check if required environment variables are set
if [ -z "$KIMAI_PORT" ] || [ -z "$ADMIN_USERNAME" ] || [ -z "$ADMIN_TOKEN" ]; then
  echo "[ERROR] Missing required environment variables. Ensure KIMAI_PORT, ADMIN_USERNAME, and ADMIN_TOKEN are set."
  exit 1
fi

# Set variables for Kimai API
KIMAI_URL="http://localhost:$KIMAI_PORT"
API_TOKEN="$ADMIN_TOKEN"
ADMIN_USERNAME="$ADMIN_USERNAME"

echo "Connecting to Kimai at: $KIMAI_URL"
echo "[DEBUG] ADMIN_USERNAME: $ADMIN_USERNAME"
echo "[DEBUG] API_TOKEN: $API_TOKEN"

# Helper function to send a POST request
function create_resource() {
    local endpoint=$1
    local data=$2

    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$KIMAI_URL/api/$endpoint" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H 'accept: application/json' \
        -H "Content-Type: application/json" \
        -d "$data")
    
    status_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')
    response_body=$(echo "$response" | sed -e 's/HTTP_STATUS:.*//')

    # Handle 200 and 201 as successful status codes
    if [[ "$status_code" -ne 200 && "$status_code" -ne 201 ]]; then
        echo "[ERROR] Failed to create resource at endpoint '$endpoint'. HTTP status code: $status_code"
        echo "[DEBUG] Response body: $response_body"
        echo "[DEBUG] Data sent: $data"
        exit 1
    else
        echo "[SUCCESS] Resource created at endpoint '$endpoint'. Response: $response_body"
    fi
}

# Helper function to check if a customer already exists
function customer_exists() {
    local customer_name="$1"
    response=$(curl -s "$KIMAI_URL/api/customers?term=$customer_name" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H 'accept: application/json')

    # Ensure jq is installed, or use alternative parsing
    if ! command -v jq &> /dev/null; then
        echo "[ERROR] jq is not installed. Please install jq to parse JSON responses."
        exit 1
    fi

    customer_count=$(echo "$response" | jq '.meta.total')

    if [ "$customer_count" -gt 0 ]; then
        return 0  # Customer exists
    else
        return 1  # Customer doesn't exist
    fi
}

# Test connection to Kimai API
echo "Testing connection to Kimai API..."
connection_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$KIMAI_URL/api/version" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "accept: application/json")
status_code=$(echo "$connection_response" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

if [[ "$status_code" -ne 200 ]]; then
    echo "[ERROR] Unable to connect to Kimai API. Status code: $status_code"
    exit 1
else
    echo "[INFO] Successfully connected to Kimai API."
fi

echo "Populating Kimai with sample data..."

# 1. Create Customers
echo "Creating Customers..."
declare -A customers=(
    ["0"]="Internal department - Marketing"
    ["1"]="Internal department - Sales"
    ["2"]="Internal department - Information Technology"
    ["3"]="Internal department - HR"
    ["4"]="External client - Client A"
    ["5"]="External client - Client B"
    ["6"]="External client - Client C"
    ["7"]="Company initiative - Research and Development"
    ["8"]="Company initiative - Employee Training and Development"
    ["9"]="Company initiative - Compliance and Legal"
)

for name in "${!customers[@]}"; do
    # Ensure the customer name with spaces is properly quoted
    customer_name="${customers[$name]}"
    comment=""
    
    echo "Checking if customer '$customer_name' exists..."
    echo "comment: '$comment'"
    
    if ! customer_exists "$customer_name"; then
        echo "Creating customer: $customer_name"
        create_resource "customers" "{\"name\":\"$customer_name\",\"comment\":\"$comment\",\"country\":\"US\",\"currency\":\"USD\",\"timezone\":\"America/New_York\",\"visible\":true}"
    else
        echo "Customer '$customer_name' already exists. Skipping creation."
    fi
done

# 2. Create Projects
echo "Creating Projects..."
declare -A projects=(
    ["0"]="Information Technology - Software Upgrades and Maintenance"
    ["1"]="Information Technology - Internal Tools Development"
    ["2"]="Marketing - Digital Campaigns"
    ["3"]="Marketing - Website Revamp"
    ["4"]="Client A - New Website Launch"
    ["5"]="Client B - Mobile App Development"
    ["6"]="HR and Administration - Employee Onboarding and Training"
)

for name in "${!projects[@]}"; do
    project_name="${projects[$name]}"
    customer="${projects[$name]}"
    echo "Creating project: $project_name for customer: $customer"
    create_resource "projects" "{\"name\":\"$project_name\",\"customer\":\"$customer\"}"
done

# 3. Create Activities
echo "Creating Activities..."
declare -a activities=(
    "Feature Development"
    "Bug Fixes"
    "Code Reviews"
    "Manual Testing"
    "Client Meetings"
    "Project Planning"
    "IT Support"
    "Employee Onboarding"
    "Research & Development"
)

for activity in "${activities[@]}"; do
    echo "Creating activity: $activity"
    create_resource "activities" "{\"name\":\"$activity\"}"
done

echo "Kimai pre-population completed successfully!"
