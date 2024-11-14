@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Load environment variables from .env file
if exist .env (
    for /f "tokens=1,2 delims==" %%a in ('findstr /r /v "^$" .env') do (
        set "%%a=%%b"
    )
) else (
    echo .env file not found!
    exit /b 1
)

:: Output the loaded environment variables
echo Loaded environment variables:
echo --------------------------------
echo MYSQL_CONTAINER: !MYSQL_CONTAINER!
echo MYSQL_DATABASE: !MYSQL_DATABASE!
echo MYSQL_USER: !MYSQL_USER!
echo MYSQL_PASSWORD: !MYSQL_PASSWORD!
echo MYSQL_ROOT_PASSWORD: !MYSQL_ROOT_PASSWORD!
echo MYSQL_PORT: !MYSQL_PORT!
echo KIMAI_CONTAINER: !KIMAI_CONTAINER!
echo KIMAI_PORT: !KIMAI_PORT!
echo ADMIN_EMAIL: !ADMIN_EMAIL!
echo ADMIN_PASSWORD: !ADMIN_PASSWORD!
echo --------------------------------
echo.

:: Define the Docker network
set NETWORK_NAME=kimai-network

:: Function to stop and remove an existing container
call :remove_container_if_exists !MYSQL_CONTAINER!
call :remove_container_if_exists !KIMAI_CONTAINER!

:: Create a Docker network if it doesn't exist
docker network inspect !NETWORK_NAME! >nul 2>&1 || docker network create !NETWORK_NAME!

:: Start MySQL container with volume for persistent data
echo Starting MySQL container on port !MYSQL_PORT!...
docker run --name !MYSQL_CONTAINER! ^
    --network !NETWORK_NAME! ^
    -e MYSQL_DATABASE=!MYSQL_DATABASE! ^
    -e MYSQL_USER=!MYSQL_USER! ^
    -e MYSQL_PASSWORD=!MYSQL_PASSWORD! ^
    -e MYSQL_ROOT_PASSWORD=!MYSQL_ROOT_PASSWORD! ^
    -p !MYSQL_PORT!:3306 ^
    -v mysql-data:/var/lib/mysql ^
    -d mysql:8.0

:: Check if MySQL container started successfully
if errorlevel 1 (
    echo Error starting MySQL container
    exit /b 1
)

:: Wait for MySQL to initialize
echo Waiting for MySQL to initialize...
timeout /t 20

:: Start Kimai container with volume for persistent data and updated DATABASE_URL
echo Starting Kimai container on port !KIMAI_PORT!...
docker run --name !KIMAI_CONTAINER! -d ^
    --network !NETWORK_NAME! ^
    -p !KIMAI_PORT!:8001 ^
    -e DATABASE_URL="mysql://!MYSQL_USER!:!MYSQL_PASSWORD!@!MYSQL_CONTAINER!:3306/!MYSQL_DATABASE!?charset=utf8mb4&serverVersion=8.0.0" ^
    -v kimai-data:/opt/kimai/var ^
    kimai/kimai2:apache

:: Check if Kimai container started successfully
if errorlevel 1 (
    echo Error starting Kimai container
    exit /b 1
)

:: Wait for Kimai to initialize
echo Waiting for Kimai to initialize...
timeout /t 10

:: Create admin user with predefined password from .env file if it doesn't exist
echo Creating admin user...
call :check_user_exists !ADMIN_EMAIL!

if !ERRORLEVEL! == 0 (
    echo Admin user with email !ADMIN_EMAIL! already exists.
) else (
    docker exec -ti !KIMAI_CONTAINER! ^
        /opt/kimai/bin/console kimai:user:create admin !ADMIN_EMAIL! ROLE_SUPER_ADMIN !ADMIN_PASSWORD!

    if errorlevel 1 (
        echo Failed to create admin user.
        exit /b 1
    ) else (
        echo Admin user created successfully!
    )
)

echo Kimai is now running at http://localhost:!KIMAI_PORT!
echo Press [CTRL+C] to stop.

:: Trap to stop the containers on exit (CTRL+C)
trap "echo Stopping containers...; docker stop !MYSQL_CONTAINER! !KIMAI_CONTAINER!; docker network rm !NETWORK_NAME!; exit" SIGINT

:: Keep the script running to prevent Docker containers from stopping
:loop
    timeout /t 1
    goto loop

:: Function to stop and remove a container if it exists
:remove_container_if_exists
    set container_name=%1
    docker ps -aq -f name=%container_name% >nul 2>&1
    if not errorlevel 1 (
        echo Stopping container: %container_name%
        docker stop %container_name%
        echo Removing container: %container_name%
        docker rm -f %container_name%
    )
    goto :eof

:: Function to check if an admin user exists
:check_user_exists
    set email=%1
    echo Checking if user with email %email% exists...
    docker exec -ti !KIMAI_CONTAINER! /opt/kimai/bin/console kimai:user:list | findstr /i "%email%" >nul
    exit /b %ERRORLEVEL%
