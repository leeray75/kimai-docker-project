@echo off
setlocal enabledelayedexpansion

:: Load environment variables from .env file
if not exist .env (
    echo .env file not found!
    exit /b 1
)

for /f "tokens=1,2 delims==" %%i in (.env) do (
    set %%i=%%j
)

:: Check if MySQL container is already running
docker ps -a --format "{{.Names}}" | findstr /i %MYSQL_CONTAINER% >nul
if %ERRORLEVEL% equ 0 (
    echo Stopping existing MySQL container...
    docker stop %MYSQL_CONTAINER% >nul
    docker rm %MYSQL_CONTAINER% >nul
)

:: Check if Kimai container is already running
docker ps -a --format "{{.Names}}" | findstr /i %KIMAI_CONTAINER% >nul
if %ERRORLEVEL% equ 0 (
    echo Stopping existing Kimai container...
    docker stop %KIMAI_CONTAINER% >nul
    docker rm %KIMAI_CONTAINER% >nul
)

:: Remove existing volumes (optional step to ensure a fresh start)
echo Removing old volumes...
docker volume rm mysql-data kimai-data >nul 2>&1

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

:: Wait until MySQL is ready
echo Waiting for MySQL to initialize...
:wait_for_mysql
docker exec %MYSQL_CONTAINER% mysqladmin ping -u%MYSQL_USER% -p%MYSQL_PASSWORD% --silent
if %ERRORLEVEL% neq 0 (
    timeout /t 5 >nul
    goto wait_for_mysql
)

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

:: Run Kimai database migrations to ensure the schema is up-to-date
echo Running Kimai database migrations...
docker exec -ti %KIMAI_CONTAINER% /opt/kimai/bin/console doctrine:migrations:migrate --no-interaction

:: Create admin user with predefined password from .env file
echo Creating admin user...
docker exec -ti %KIMAI_CONTAINER% ^
    /opt/kimai/bin/console kimai:user:create admin %ADMIN_EMAIL% ROLE_SUPER_ADMIN %ADMIN_PASSWORD%

echo Kimai is now running at http://localhost:%KIMAI_PORT%
echo Press any key to stop...

:: Wait for user input to stop the containers
pause

:: Stop the containers without removing the volumes
echo Stopping containers...
docker stop %MYSQL_CONTAINER% %KIMAI_CONTAINER%

endlocal
