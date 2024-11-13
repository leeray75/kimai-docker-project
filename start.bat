@echo off
setlocal

REM Load environment variables from .env file
for /f "usebackq tokens=* delims=" %%x in (.env) do set %%x

echo Starting MySQL container...
docker run -d --name %MYSQL_CONTAINER% ^
  --env MYSQL_DATABASE=%MYSQL_DATABASE% ^
  --env MYSQL_USER=%MYSQL_USER% ^
  --env MYSQL_PASSWORD=%MYSQL_PASSWORD% ^
  --env MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD% ^
  -p %MYSQL_PORT%:3306 ^
  --restart unless-stopped ^
  --volume kimai-mysql-data:/var/lib/mysql ^
  --network kimai-network ^
  mysql:8.0

echo Waiting for MySQL to initialize...
timeout /t 15 >nul

echo Starting Kimai container...
docker run -d --name %KIMAI_CONTAINER% ^
  --env DATABASE_URL=mysql://%MYSQL_USER%:%MYSQL_PASSWORD%@%MYSQL_CONTAINER%:3306/%MYSQL_DATABASE% ^
  --env ADMIN_MAIL=%ADMIN_EMAIL% ^
  --env ADMIN_PASSWORD=%ADMIN_PASSWORD% ^
  -p %KIMAI_PORT%:8001 ^
  --restart unless-stopped ^
  --network kimai-network ^
  --volume kimai-data:/opt/kimai ^
  kimai/kimai2:latest

echo Waiting for Kimai to initialize...
timeout /t 20 >nul

echo Creating admin user...
docker exec -it %KIMAI_CONTAINER% bin/console kimai:create-user admin %ADMIN_EMAIL% ROLE_SUPER_ADMIN

echo Kimai is up and running!
echo Access it at: http://localhost:%KIMAI_PORT%
echo You will be prompted to set the admin password in the terminal.

endlocal
pause
