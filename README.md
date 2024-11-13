# Kimai Docker Project

This project sets up a **local Kimai instance** using Docker, complete with MySQL as the database backend. Kimai is a powerful, open-source time-tracking solution for teams and freelancers.

⚠️ **Important Notice**  
This project is intended **for demo and testing purposes only**. It is not recommended for production use. For a stable production environment, please set up Kimai using a **Docker Compose** configuration with appropriate security measures, persistent volumes, and reverse proxies.

---

## Prerequisites
To run this project, make sure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Git](https://git-scm.com/)
- [Bash](https://www.gnu.org/software/bash/) (for Unix systems) or a compatible terminal on Windows

---

## Quick Start Guide

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/kimai-docker-project.git
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

**For Windows**:
```powershell
start.bat
```

This will pull the necessary Docker images and start the MySQL and Kimai containers.

---

### 4. Access Kimai
Once the application is running, open your browser and navigate to:

```
http://localhost:8001
```

- **Email**: `admin@example.com`
- **Password**: `admin`

---

## Stopping and Cleaning Up
To stop and remove the running containers, use the following commands:

```bash
docker stop kimai-mysql kimai-app
docker rm kimai-mysql kimai-app
```

To remove all data (including volumes):

```bash
docker-compose down --volumes
```

---

## For Production Use
For deploying Kimai in a production environment, it is highly recommended to use a **Docker Compose** setup with persistent volumes and proper reverse proxy configurations. Refer to the [official Kimai documentation](https://github.com/kimai/kimai2) for more details on production deployments.

---

## Detailed Setup Instructions
For detailed step-by-step instructions on running this project on your local machine, please refer to the [SETUP.md](SETUP.md) file.

---

## License
This project is open-source and available under the [MIT License](LICENSE).
