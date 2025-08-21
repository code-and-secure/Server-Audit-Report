#!/bin/bash

# server_audit_report.sh
# Generates a comprehensive HTML server audit report with CSS styling,
# including advanced checks for security patching, server workload, health, and internet connectivity.

REPORT="server_audit_report.html"
DATE=$(date)
HOSTNAME=$(hostname)

# HTML header and CSS
cat > $REPORT <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Server Audit Report - $HOSTNAME</title>
<style>
body { font-family: Arial, sans-serif; margin: 40px; background: #f8f8f8; color: #222; }
h1, h2 { color: #2a4d69; }
section { background: #fff; margin-bottom: 20px; border-radius: 6px; box-shadow: 0 2px 6px #ddd; padding: 20px; }
pre { background: #f0f0f0; padding: 10px; border-radius: 4px; font-size: 0.96em; overflow-x: auto; }
strong { color: #4b86b4; }
hr { border: 0; border-top: 1px solid #eee; margin: 24px 0; }
.warning { color: #b94a48; font-weight: bold; }
.good { color: #468847; font-weight: bold; }
</style>
</head>
<body>
<h1>Server Audit Report</h1>
<p><strong>Date:</strong> $DATE</p>
<p><strong>Hostname:</strong> $HOSTNAME</p>
<hr>
EOF

# 1. Host Information
{
echo "<section><h2>1. Host Information</h2><pre>"
hostnamectl
echo -e "\nUptime:"
uptime -p
echo -e "\nOS Release:"
cat /etc/os-release 2>/dev/null
echo "</pre></section>"
} >> $REPORT

# 2. CPU Information
{
echo "<section><h2>2. CPU Information</h2><pre>"
lscpu
echo -e "\nCPU Usage:"
top -bn1 | grep "Cpu(s)"
echo "</pre></section>"
} >> $REPORT

# 3. Memory (RAM) and Swap Information
{
echo "<section><h2>3. Memory (RAM & Swap)</h2><pre>"
free -h
echo -e "\n/proc/meminfo (Top 20):"
head -20 /proc/meminfo
echo "</pre></section>"
} >> $REPORT

# 4. Disk Usage
{
echo "<section><h2>4. Disk Usage</h2><pre>"
df -hT
echo -e "\nMount Points:"
lsblk
echo "</pre></section>"
} >> $REPORT

# 5. Network Interfaces & IP
{
echo "<section><h2>5. Network Interfaces & IP</h2><pre>"
ip addr show
echo -e "\nDefault Gateway:"
ip route | grep default
echo "</pre></section>"
} >> $REPORT

# 6. Open Ports & Listening Services
{
echo "<section><h2>6. Open Ports & Listening Services</h2><pre>"
ss -tulpen
echo -e "\nNetstat Output:"
netstat -tulnp 2>/dev/null | grep LISTEN
echo "</pre></section>"
} >> $REPORT

# 7. Firewall Status
{
echo "<section><h2>7. Firewall Status</h2><pre>"
if command -v ufw >/dev/null; then
    echo "UFW Status:"
    ufw status verbose
fi
if command -v firewall-cmd >/dev/null; then
    echo -e "\nFirewalld Status:"
    firewall-cmd --state
    firewall-cmd --list-all
fi
if command -v iptables >/dev/null; then
    echo -e "\nIptables Rules:"
    iptables -L -n -v
fi
echo "</pre></section>"
} >> $REPORT

# 8. Blocked or Failed Services
{
echo "<section><h2>8. Blocked or Failed Services</h2><pre>"
echo "Systemd Failed Services:"
systemctl --failed
echo "</pre></section>"
} >> $REPORT

# 9. Running Services and Daemons
{
echo "<section><h2>9. Running Services & Daemons</h2><pre>"
systemctl list-units --type=service --state=running
echo "</pre></section>"
} >> $REPORT

# 10. User Accounts & Last Logins
{
echo "<section><h2>10. User Accounts & Last Logins</h2><pre>"
awk -F: '{ print $1":"$3":"$7 }' /etc/passwd
echo -e "\nLast Logins:"
last -a | head -20
echo "</pre></section>"
} >> $REPORT

# 11. Scheduled Tasks (Cron)
{
echo "<section><h2>11. Scheduled Tasks (Cron)</h2><pre>"
crontab -l 2>/dev/null
echo -e "\nSystem Cron Jobs:"
ls /etc/cron* 2>/dev/null
echo "</pre></section>"
} >> $REPORT

# 12. Recent System Logs (Errors)
{
echo "<section><h2>12. Recent System Logs (Errors)</h2><pre>"
journalctl -p 3 -xb | head -20
echo "</pre></section>"
} >> $REPORT

# 13. Hardware Summary
{
echo "<section><h2>13. Hardware Summary</h2><pre>"
if command -v lshw >/dev/null; then
  lshw -short
else
  echo "lshw not installed or not run as root. Skipping detailed hardware summary."
fi
echo "</pre></section>"
} >> $REPORT

# 14. Security Updates with Internet Check
{
echo "<section><h2>14. Pending Security Updates</h2><pre>"
PATCHES=""
INTERNET_STATUS="unknown"
if command -v apt >/dev/null; then
    PATCHES=$(apt list --upgradable 2>/dev/null | grep security)
elif command -v yum >/dev/null; then
    PATCHES=$(yum check-update --security 2>/dev/null)
elif command -v dnf >/dev/null; then
    PATCHES=$(dnf updateinfo list security all 2>/dev/null)
fi

if [ -z "$PATCHES" ]; then
    # Check for internet connectivity
    if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        INTERNET_STATUS="yes"
        echo "No security patches are available or all security updates are already installed."
    else
        INTERNET_STATUS="no"
        echo "<span class=\"warning\">No internet service is available for checking the security patches.</span>"
    fi
else
    echo "$PATCHES"
fi
echo "</pre></section>"
} >> $REPORT

# 15. Workload Statistics
{
echo "<section><h2>15. Server Workload</h2><pre>"
echo "Load Average (1, 5, 15 min):"
cat /proc/loadavg
echo -e "\nTop 5 Processes by CPU:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
echo -e "\nTop 5 Processes by Memory:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -6
echo "</pre></section>"
} >> $REPORT

# 16. Health Checks
{
echo "<section><h2>16. Server Health Checks</h2><pre>"
HEALTH_OK=1

# CPU Load check
LOAD1=$(awk '{print $1}' /proc/loadavg)
CPUS=$(nproc)
if (( $(echo "$LOAD1 > $CPUS" | bc -l) )); then
  echo "<span class=\"warning\">Warning: 1-min load average ($LOAD1) exceeds CPU count ($CPUS)</span>"
  HEALTH_OK=0
else
  echo "<span class=\"good\">CPU Load Normal</span>"
fi

# RAM check
MEMTOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEMFREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEMPERC=$(awk "BEGIN {printf \"%.1f\",($MEMFREE/$MEMTOTAL)*100}")
if (( $(echo "$MEMPERC < 10.0" | bc -l) )); then
  echo "<span class=\"warning\">Warning: Less than 10% RAM free</span>"
  HEALTH_OK=0
else
  echo "<span class=\"good\">RAM usage is healthy</span>"
fi

# Disk usage check
DISKFULL=$(df -h | awk 'NR>1 && $5+0 > 90 {print $1 " " $5}')
if [[ -n "$DISKFULL" ]]; then
  echo "<span class=\"warning\">Warning: Disks over 90% full:</span>"
  echo "$DISKFULL"
  HEALTH_OK=0
else
  echo "<span class=\"good\">All disk usage under 90%</span>"
fi

# Swap usage check
SWAPTOTAL=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
SWAPFREE=$(grep SwapFree /proc/meminfo | awk '{print $2}')
if [ "$SWAPTOTAL" -gt 0 ]; then
  SWAPPERC=$(awk "BEGIN {printf \"%.1f\",(($SWAPTOTAL-$SWAPFREE)/$SWAPTOTAL)*100}")
  if (( $(echo "$SWAPPERC > 80.0" | bc -l) )); then
    echo "<span class=\"warning\">Warning: Swap usage exceeds 80%</span>"
    HEALTH_OK=0
  else
    echo "<span class=\"good\">Swap usage is healthy</span>"
  fi
fi

if [ "$HEALTH_OK" = "1" ]; then
  echo "<span class=\"good\">Overall server health is OK.</span>"
else
  echo "<span class=\"warning\">Some health checks failed. Please review the warnings above.</span>"
fi

echo "</pre></section>"
} >> $REPORT

# HTML Footer
cat >> $REPORT <<EOF
<hr>
<p style="text-align:center;color:#888;font-size:0.95em">
Server Audit Report generated by <strong>server_audit_report.sh</strong> on $DATE
</p>
</body>
</html>
EOF

echo "HTML server audit report generated: $REPORT"
