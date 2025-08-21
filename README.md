# Server Audit Report Script

This repository (`@code-and-secure/Server-Audit-Report`) contains a **comprehensive Bash script** that generates a detailed server audit report in HTML format with embedded tables for easy viewing. The report covers all major aspects of server health, resource usage, workload, security status, and more.

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
- **Security patch status**
- **Current server workload**
- **Automatic health checks**

---

## Usage

### 1. Download the script

Clone this repository or download the script file:

```bash
git clone https://github.com/code-and-secure/Server-Audit-Report.git
cd Server-Audit-Report
# OR download just the script:
wget https://raw.githubusercontent.com/code-and-secure/Server-Audit-Report/main/server_audit_report.sh
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
- The HTML report uses embedded tables for clear and organized presentation.
- Handles network connectivity gracefully: if no internet is available, it notifies this in the security patch section.

---

## Contributions

Pull requests and suggestions are welcome!

---

**Repository:** [@code-and-secure/Server-Audit-Report](https://github.com/code-and-secure/Server-Audit-Report)
