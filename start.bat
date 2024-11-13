@echo off
setlocal enabledelayedexpansion

:: Load environment variables from .env file
if not exist .env (
    echo .env file not found!
    exit /b 1
)
for /f "tokens=1,2 delims==" %%i in ('.env') do (
    set %%i=%%j
)

:: Start MySQL container with volume for persistent data
echo Starting MySQL container...
docker run --name %MYSQL_CONTAINER% ^
    -e MYSQL_DATABASE=%MYSQL_DATABASE% ^
    -e MYSQL_USER=%MYSQL_USER% ^
    -e MYSQL_PASSWORD=%MYSQL_PASSWORD% ^
    -e MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD% ^
    -p %MYSQL_PORT%:3306 ^
    -v mysql-data:/var/lib/mysql ^
    -d mysql:8.0

:: Wait for MySQL to initialize
echo Waiting for MySQL to initialize...
timeout /t 20

:: Start Kimai container with volume for persistent data
echo Starting Kimai container...
docker run --name %KIMAI_CONTAINER% -d ^
    -p %KIMAI_PORT%:8001 ^
    -e DATABASE_URL="mysql://%MYSQL_USER%:%MYSQL_PASSWORD%@host.docker.internal:%MYSQL_PORT%/%MYSQL_DATABASE%?charset=utf8mb4&serverVersion=8.0.0" ^
    -v kimai-data:/opt/kimai/var ^
    kimai/kimai2:apache

:: Wait for Kimai to initialize
echo Waiting for Kimai to initialize...
timeout /t 10

:: Create admin user if not already created
echo Creating admin user...
docker exec -ti %KIMAI_CONTAINER% ^
    /opt/kimai/bin/console kimai:user:create admin %ADMIN_EMAIL% ROLE_SUPER_ADMIN

echo Kimai is now running at http://localhost:%KIMAI_PORT%
echo Press any key to stop...
pause

:: Stop the containers when the user presses a key
docker stop %MYSQL_CONTAINER% %KIMAI_CONTAINER%
docker rm %MYSQL_CONTAINER% %KIMAI_CONTAINER%

endlocal
