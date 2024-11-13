# Kimai Docker Project - Detailed Setup Guide

This guide provides detailed instructions on how to set up and run the Kimai application using Docker on your local machine.

## Prerequisites
Before starting, ensure that you have the following software installed on your machine:

1. **Docker** - [Install Docker](https://docs.docker.com/get-docker/)
2. **Git** - [Install Git](https://git-scm.com/downloads)
3. **Bash** (for Unix-based systems) or a compatible terminal on Windows.

---

## Step 1: Clone the Repository
To get started, clone the project repository:

```bash
git clone https://github.com/leeray75/kimai-docker-project.git
cd kimai-docker-project
```

---

## Step 2: Configure Environment Variables
1. Copy the `.env.example` file to `.env`:

    ```bash
    cp .env.example .env
    ```

2. Open the `.env` file in a text editor and update any necessary variables:

    ```env
    # Docker container names
    MYSQL_CONTAINER=kimai-mysql
    KIMAI_CONTAINER=kimai-app

    # Ports
    MYSQL_PORT=3399
    KIMAI_PORT=8001

    # MySQL database configuration
    MYSQL_DATABASE=kimai
    MYSQL_USER=kimai
    MYSQL_PASSWORD=kimai
    MYSQL_ROOT_PASSWORD=kimai

    # Kimai admin credentials
    ADMIN_EMAIL=admin@example.com
    ADMIN_PASSWORD=admin
    ```

> **Note**: Make sure the ports specified (`MYSQL_PORT` and `KIMAI_PORT`) are not being used by other applications.

---

## Step 3: Running the Application

### For Unix-based Systems (Linux, macOS)
Run the included shell script:

```bash
./start.sh
```

### For Windows Systems
Run the batch script:

```powershell
./start.bat
```

---

## Step 4: Access the Kimai Application
Once the containers are running, open your browser and visit:

```
http://localhost:8001
```

Log in using the credentials you set in the `.env` file:

- **Email**: `admin@example.com`
- **Password**: `admin`

---

## Step 5: Stopping and Cleaning Up
To stop the running containers:

```bash
docker stop kimai-mysql kimai-app
```

To remove the containers:

```bash
docker rm kimai-mysql kimai-app
```

If you want to completely remove all Docker data (including volumes):

```bash
docker-compose down --volumes
```

---

## Troubleshooting

### Database Connection Issues
If you encounter errors related to the database connection, try the following:

1. Ensure that the `DATABASE_URL` is correctly set in the `.env` file.
2. Try replacing `host.docker.internal` with `localhost` if you're on a Unix-based system.

### Port Conflicts
If the specified ports are already in use, update the values in the `.env` file and restart the application.

---

## Additional Resources
- [Kimai Documentation](https://www.kimai.org/documentation/)
- [Docker Documentation](https://docs.docker.com/)

---

## License
This project is licensed under the [MIT License](LICENSE).