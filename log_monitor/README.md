
# 🔍 Real-time Log Monitor Script (Bash)

  

  

  

  

A **production-grade Bash script** for **real-time monitoring of web server logs** (Apache, Nginx, custom apps).  
It detects **HTTP 500-series errors**, applies **threshold-based alerting**, and sends **HTML email notifications** with detailed diagnostics.

Designed for **DevOps, SRE, and Linux automation workflows**.

----------

## ✨ Key Features

-   🚨 **Real-time detection** of HTTP 5xx errors
    
-   📊 **Threshold-based alerts** (configurable)
    
-   ⏱️ **Time-window analysis** to avoid alert noise
    
-   🔁 **Log rotation safe** (tracks file offsets)
    
-   📧 **Rich HTML email alerts**
    
-   🛑 **Alert cooldown mechanism**
    
-   🧠 **Stateful monitoring** (no duplicate alerts)
    
-   🔐 **Lock file protection** (prevents multiple instances)
    
-   📜 **Syslog integration**
    
-   🧪 **Test alert support**
    
-   🖥️ **Daemon & foreground modes**
    

----------

## 📂 Supported Logs

-   Apache access logs
    
-   Nginx access logs
    
-   Custom application logs
    
-   Wildcard log paths
    
    `/var/log/application/*.log` 
    

----------

## 🛠️ Requirements

-   Linux system
    
-   Bash 4.x+
    
-   One of the following for email:
    
    -   `sendmail`
        
    -   `mail`
        
    -   `mailx`
        
-   Optional:
    
    -   Local SMTP relay (Postfix / Exim)
        

----------

## 📦 Installation

`git clone https://github.com/<your-username>/log-monitor-script.git cd log-monitor-script chmod +x logmonitor.sh` 

----------

## ⚙️ Configuration

### Default Config File

`~/.logmonitor.conf` 

Generate it automatically:

`./logmonitor.sh --init-config` 

### Example Configuration

`LOG_FILE="/var/log/nginx/access.log" 
ERROR_PATTERN="HTTP/[0-9.]* 5[0-9][0-9]" 
ALERT_EMAIL="admin@example.com"
CHECK_INTERVAL=60
ALERT_THRESHOLD=5
TIME_WINDOW=300
ALERT_COOLDOWN=1800
ENABLE_SYSLOG=true DEBUG_MODE=false` 

----------

## ▶️ Usage

### Run with defaults

`./logmonitor.sh` 

### Run in background (daemon)

`./logmonitor.sh --daemon` 

### Monitor a specific log file

`./logmonitor.sh --log /var/log/nginx/access.log --email ops@example.com` 

### Enable verbose/debug logging

`./logmonitor.sh --verbose` 

### View current monitoring statistics

`./logmonitor.sh --stats` 

### Send a test alert

`./logmonitor.sh --test-alert` 

### Stop the daemon

`./logmonitor.sh --stop` 

----------

## 📊 Alert Logic (How It Works)

1.  Reads **only new log entries** since last check
    
2.  Matches **HTTP 500–599 status codes**
    
3.  Counts errors within the **time window**
    
4.  Sends alert **only if threshold is exceeded**
    
5.  Applies **cooldown** to prevent alert flooding
    
6.  Saves state to `/tmp/logmonitor_state.tmp`
    

----------

## 📧 Email Alert Preview

Alert emails include:

-   Hostname
    
-   Timestamp
    
-   Error count
    
-   Log file path
    
-   Threshold details
    
-   Parsed request info:
    
    -   Client IP
        
    -   HTTP method
        
    -   URL
        
    -   Status code
        

HTML-styled for **readability in production alerts**.

----------

## 🔐 Safety & Reliability

-   Lock file: `/var/lock/logmonitor.lock`
    
-   Prevents duplicate instances
    
-   Handles log rotation safely
    
-   Graceful shutdown on SIGINT / SIGTERM
    
-   Fallback alert storage if email fails
    

----------

## 📁 Project Structure
```text
.
├── logmonitor.sh
├── ~/.logmonitor.conf
├── /tmp/logmonitor_state.tmp
└── /var/lock/logmonitor.lock

----------

## 👤 Author

**Harini Muruganantham**  
DevOps | Linux | Shell Scripting | Cloud Automation