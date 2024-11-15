# Kimai Docker Project

This project sets up a **local Kimai instance** using Docker, complete with MySQL as the database backend. Kimai is a powerful, open-source time-tracking solution for teams and freelancers.

⚠️ **Important Notice**  
This project is intended **for demo and testing purposes only**. It is not recommended for production use. For a stable production environment, please set up Kimai using a **Docker Compose** configuration with appropriate security measures, persistent volumes, and reverse proxies.

---

## Prerequisites
To run this project, make sure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Git](https://git-scm.com/)
- [Bash](https://www.gnu.org/software/bash/) (for Unix systems) or a compatible terminal on Windows.  
  **Windows Users**: It is **strongly recommended** to use **Windows Subsystem for Linux (WSL)** for a better compatibility experience. Please refer to [WSL Troubleshooting Guide](WSL_TROUBLESHOOTING.md) if you encounter any issues.

---

## Quick Start Guide

### 1. Clone the Repository
```bash
git clone https://github.com/leeray75/kimai-docker-project.git
cd kimai-docker-project
```

### 2. Copy the Example Environment File
```bash
cp .env.example .env
```

Edit the `.env` file to adjust any variables as needed, such as ports and admin credentials.

---

### 3. Run the Application

**For Unix-based systems (Linux, macOS)**:
```bash
./start.sh
```

**For Windows** (WSL recommended):
```powershell
./start.bat
```

This will pull the necessary Docker images and start the MySQL and Kimai containers. The admin user will be created automatically using the credentials from the `.env` file, including the password.

---

### 4. Access Kimai
Once the application is running, open your browser and navigate to:

```
http://localhost:8001
```

- **Username**: `admin`
- **Password**: The password specified in the `.env` file under `ADMIN_PASSWORD`.

---

## Corporate Setup Guide
For configuring Kimai for a **corporate environment**, including setting up **Customers, Projects, Activities, and Tags**, please refer to the [Corporate Setup Guide](GETTING_STARTED_CORPORATE_SETUP.md).

---

## Managing Docker Containers

After running the `start` command, if you need to **start**, **stop**, or **restart** the Kimai and MySQL containers, it is recommended to use the Docker Desktop application or the Docker CLI.

### Using Docker Desktop
1. Open the Docker Desktop application.
2. Locate the `kimai-mysql` and `kimai-app` containers.
3. Use the available controls to **start**, **stop**, or **restart** the containers.

### Using Docker CLI
Alternatively, you can use the Docker CLI for container management:

- **Stop the containers**:
  ```bash
  docker stop kimai-mysql kimai-app
  ```

- **Start the containers**:
  ```bash
  docker start kimai-mysql kimai-app
  ```

- **Restart the containers**:
  ```bash
  docker restart kimai-mysql kimai-app
  ```

- **Remove the containers**:
  ```bash
  docker rm kimai-mysql kimai-app
  ```

---

## For Production Use
For deploying Kimai in a production environment, it is highly recommended to use a **Docker Compose** setup with persistent volumes and proper reverse proxy configurations. Refer to the [official Kimai documentation](https://www.kimai.org/documentation/docker-compose.html) for more details on production deployments.

---

## Detailed Setup Instructions
For detailed step-by-step instructions on running this project on your local machine, please refer to the [SETUP.md](SETUP.md) file.

---

## License
This project is open-source and available under the [MIT License](LICENSE).

