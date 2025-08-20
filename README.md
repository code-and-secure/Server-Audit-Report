# Server-Audit-Report# Server Audit Report Script

This repository contains a **comprehensive Bash script** that generates a detailed server audit report in HTML format with embedded CSS for easy viewing. The report covers all major aspects of server health, resource usage, workload, security status, and more.

---

## Features

- **Host and OS details**
- **CPU, RAM, and swap statistics**
- **Disk usage and mount points**
- **Network interfaces and IP addresses**
- **Open ports and listening services**
- **Firewall status and rules**
- **Blocked or failed services**
- **Running services and daemons**
- **User accounts and recent logins**
- **Scheduled cron jobs**
- **Recent critical system logs**
- **Hardware summary**
- **Security patch status** (checks for connectivity before reporting)
- **Current server workload** (load averages and top processes)
- **Automatic health checks** (CPU, RAM, disk, swap)

---

## Usage

### 1. Download the script

Clone this repository or download the script file:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME
# OR download just the script:
wget https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME/main/server_audit_report.sh
```

### 2. Make the script executable

```bash
chmod +x server_audit_report.sh
```

### 3. Run the script (recommended as root for full details)

```bash
sudo ./server_audit_report.sh
```

> The script will generate a file named `server_audit_report.html` in the current directory.

### 4. View the report

Open `server_audit_report.html` in your web browser.

---

## Requirements

- Bash shell
- Standard Unix/Linux utilities: `lscpu`, `free`, `df`, `lsblk`, `ip`, `ss`, `netstat`, `systemctl`, `awk`, `ps`, `journalctl`, etc.
- Optional for more details:  
  - `lshw` (for hardware summary)  
  - `ufw`, `firewalld`, or `iptables` (for firewall status)  
  - `apt`, `yum`, or `dnf` (for security update status)  

Install missing tools using your package manager, e.g.,

```bash
# For Debian/Ubuntu:
sudo apt update
sudo apt install lshw net-tools

# For CentOS/RHEL:
sudo yum install lshw net-tools
```

---

## Notes

- **Run as root** for the most complete results (especially hardware info, logs, and systemd services).
- The script is designed for Linux servers but may work on other Unix-like systems with minor tweaks.
- The HTML report uses embedded CSS for clear and organized presentation.
- Handles network connectivity gracefully: if no internet is available, it notifies this in the security patch section.

---

## Example

![screenshot of HTML report](screenshot.png)

---

## License

This project is licensed under the MIT License.  
See [LICENSE](LICENSE) for more information.

---

## Contributions

Pull requests and suggestions are welcome!

---

## Author

[Your Name or GitHub handle]
