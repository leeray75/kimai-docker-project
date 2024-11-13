# Kimai Docker Project

This project sets up a local Kimai instance using Docker, complete with MySQL as the database backend. Kimai is a powerful, open-source time-tracking solution for teams and freelancers.

## Prerequisites
To run this project, make sure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Git](https://git-scm.com/)
- [Bash](https://www.gnu.org/software/bash/) (for Unix systems) or a compatible terminal on Windows

## Quick Start Guide

### 1. Clone the repository
```bash
git clone https://github.com/your-username/kimai-docker-project.git
cd kimai-docker-project
```

### 2. Copy the example environment file
```bash
cp .env.example .env
```

Edit the `.env` file to adjust any variables as needed.

### 3. Run the application
For Unix-based systems:
```bash
./start.sh
```

For Windows:
```powershell
start.bat
```

### 4. Access Kimai
Once the application is running, visit [http://localhost:8001](http://localhost:8001) in your browser.

## Stopping and Cleaning Up
To stop and remove the running containers, use:
```bash
docker stop kimai-mysql kimai-app
docker rm kimai-mysql kimai-app
```

## Detailed Setup Instructions
For detailed step-by-step instructions on running this project on your local machine, please refer to the [SETUP.md](SETUP.md) file.

## License
This project is open-source and available under the [MIT License](LICENSE).
