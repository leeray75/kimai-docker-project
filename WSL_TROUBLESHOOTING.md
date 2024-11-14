# WSL Troubleshooting Guide

If you're using **Windows Subsystem for Linux (WSL)** to run this project, here are some common troubleshooting steps for resolving issues with Docker and Kimai:

## 1. Docker Not Running in WSL
If you are unable to run Docker commands inside your WSL terminal, ensure that Docker Desktop is installed and running on your Windows machine. Docker Desktop must be set to integrate with WSL. Follow these steps:

- Open Docker Desktop.
- Go to **Settings** > **General** and ensure **Use the WSL 2 based engine** is enabled.
- Under **Settings** > **Resources**, ensure that your WSL distributions are enabled for Docker.

Restart Docker Desktop and your WSL session.

## 2. Docker CLI Not Working in WSL
If Docker commands fail with an error like `docker: command not found`, it might be because Docker is not properly installed in your WSL distribution. Ensure that you have Docker Desktop installed on Windows and integrated with WSL. Alternatively, you can install Docker inside your WSL environment by following [Docker's official installation guide](https://docs.docker.com/docker-for-windows/wsl/).

## 3. File Permission Issues
If you encounter permission issues when running scripts like `start.sh` or `start.bat` in WSL, ensure that the script has executable permissions:

```bash
chmod +x start.sh
```

This command grants execute permissions to the script.

## 4. Docker Network Issues
Sometimes, Docker may encounter network issues when running containers in WSL. If the containers are not able to communicate with each other, ensure that Docker's network settings are correct. You can reset Docker's network configuration in Docker Desktop settings.

## 5. Docker Daemon Startup Issues
If Docker is not starting properly within WSL, try restarting both Docker Desktop and WSL:

```bash
wsl --shutdown
```

Then restart Docker Desktop.

If problems persist, you can also try running the following command inside WSL to restart the Docker service:

```bash
sudo service docker restart
```

## 6. Troubleshooting `^M` Characters in Scripts (Line Ending Issues)
If you encounter issues with scripts like `start.sh` in WSL, where you see `^M` characters at the end of lines or experience unexpected behavior when running the scripts, this is likely due to a **line-ending mismatch** between Windows and Unix systems.

Windows uses **CRLF** (Carriage Return + Line Feed) line endings, while Unix-based systems like Linux and macOS use **LF** (Line Feed) line endings. When you open a script in WSL that was created in Windows, it can sometimes have these Windows line endings (`^M`), causing issues when the script is executed.

### Fixing the `^M` Characters

1. **Use `dos2unix` to Convert Line Endings:**

   You can convert the file to use Unix line endings with the `dos2unix` tool. This tool should be installed by default in most Linux distributions. If it's not installed, you can install it with:

   ```bash
   sudo apt-get install dos2unix
   ```

   After installing `dos2unix`, run the following command on your script files:

   ```bash
   dos2unix start.sh
   ```

   This will convert the line endings in `start.sh` (or any other affected files) from Windows-style CRLF to Unix-style LF.

2. **Manually Remove `^M` Characters with `sed`:**

   If you don’t want to install `dos2unix`, you can use `sed` to remove the `^M` characters directly:

   ```bash
   sed -i 's/\r//' start.sh
   ```

   This command removes the carriage return characters from the file, leaving only the line feed (`LF`) endings.

3. **Ensure Correct Line Endings in Git:**

   If you’re cloning or pulling the project from a Git repository and encountering `^M` characters, you may want to ensure that Git automatically converts line endings when checking out files. To enable this, run the following in your Git configuration:

   ```bash
   git config --global core.autocrlf input
   ```

   This setting ensures that Git will convert CRLF to LF on checkout, but it won’t modify LF endings when checking files back in.

---

## 7. General Troubleshooting
- Ensure your `.env` file is correctly configured with valid MySQL and Kimai container details.
- Check the Docker logs to diagnose container startup issues:

```bash
docker logs kimai-mysql
docker logs kimai-app
```

---

For additional help or specific error codes, consult the [Docker documentation](https://docs.docker.com/).

