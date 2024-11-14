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

:: Function to check if a Docker container exists and remove it
:remove_container
docker ps -a --format "{{.Names}}" | findstr /i %1 >nul
if %ERRORLEVEL% equ 0 (
    echo Stopping and removing existing container: %1...
    docker stop %1 >nul
    docker rm %1 >nul
)
goto :eof

:: Remove existing MySQL container if it exists
call :remove_container %MYSQL_CONTAINER%

:: Remove existing Kimai container if it exists
call :remove_container %KIMAI_CONTAINER%

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
set /a retries=10
:wait_for_mysql
docker exec %MYSQL_CONTAINER% mysqladmin ping -u%MYSQL_USER% -p%MYSQL_PASSWORD% --silent >nul 2>&1
if %ERRORLEVEL% neq 0 (
    set /a retries-=1
    if %retries% leq 0 (
        echo MySQL failed to initialize after multiple attempts. Exiting...
        exit /b 1
    )
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
timeout /t 10 >nul

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
