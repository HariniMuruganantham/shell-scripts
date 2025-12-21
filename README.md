
# 🐧 Linux & Shell Scripting – DevOps Automation Projects

  

  

  

  

A **curated collection of real-world Linux & Bash automation projects**, designed to demonstrate **core DevOps, system administration, and SRE skills**.

Each project is implemented as a **standalone, production-grade shell script**, following best practices such as logging, configurability, safety checks, and automation readiness.

----------

## 🎯 Repository Objective

This repository focuses on:

-   Linux internals & system observability
    
-   Shell scripting for real automation use-cases
    
-   DevOps-style monitoring, alerting, and maintenance tasks
    
-   Interview-ready, portfolio-quality scripts
    

All scripts are:

-   ✅ Modular
    
-   ✅ Config-driven
    
-   ✅ Cloud/VM friendly (EC2 compatible)
    
-   ✅ Beginner-to-advanced DevOps aligned
    

----------

## 📁 Repository Structure


```
linux-shell-devops-projects/
│
├── system-info/
│   └── system_info.sh
│   └── README.md
│
├── log-monitor/
│   └── log_monitor.sh
│   └── README.md
│
├── system-monitor/
│   └── system_monitor.sh
│   └── README.md
│
├── backup-script/
│   └── backup_and_cleanup.sh
│   └── README.md
│
└── README.md


Each folder represents **one independent project** with a single main script.
```
----------

## 🚀 Projects Overview

### 1️⃣ Comprehensive System Information Script

📄 **File:** `system_info/system_info.sh`

**Purpose:**  
Collects detailed system information in a structured and readable format.

**Covers:**

-   OS & kernel details
    
-   CPU, memory, disk usage
    
-   Network interfaces & IPs
    
-   Uptime & load average
    
-   Hardware summary
    

**Use Case:**  
System audits, troubleshooting, server documentation, learning Linux internals.

----------

### 2️⃣ Log Monitor Script (HTTP 500 Alerting)

📄 **File:** `log_monitor/log_monitor.sh`

**Purpose:**  
Real-time monitoring of web server logs with **email alerts for HTTP 5xx errors**.

**Key Features:**

-   Apache / Nginx log support
    
-   Regex-based error detection
    
-   Threshold & cooldown logic
    
-   HTML email alerts
    
-   Log rotation safe
    
-   Daemon & foreground modes
    

**Use Case:**  
Production incident detection, SRE alerting, server health monitoring.

----------

### 3️⃣ System & Container Monitor Script

📄 **File:** `system_monitor/system_monitor.sh`

**Purpose:**  
Automated **system + Docker container performance monitoring** with report generation.

**Key Features:**

-   CPU, memory, disk & network metrics
    
-   Docker container CPU/memory/I/O stats
    
-   Optional Kubernetes visibility
    
-   CSV-based historical metrics
    
-   Daily / Weekly / Monthly HTML reports
    
-   Live terminal dashboard
    

**Use Case:**  
Lightweight observability, EC2 monitoring, DevOps learning alternative to Prometheus.

----------

### 4️⃣ Automated Backup & Disk Cleanup Script

📄 **File:** `backup_script/backup_and_cleanup.sh`

**Purpose:**  
Automates backups and disk space management.

**Key Features:**

-   Configurable backup directories
    
-   Timestamped compressed archives
    
-   Old backup retention policy
    
-   Disk cleanup for logs & temp files
    
-   Safe deletion with logging
    

**Use Case:**  
Routine server maintenance, cron-based automation, storage optimization.

----------

## 🛠️ Requirements

-   Linux OS (Ubuntu / Amazon Linux / Debian / RHEL)
    
-   Bash 4.x+
    
-   Common utilities:
    
    -   `awk`, `sed`, `df`, `top`, `ps`
        
-   Optional:
    
    -   Docker (for container monitoring)
        
    -   Mail utilities (for log alerts)
        

No heavy external dependencies.

----------

## ▶️ How to Use

`git clone https://github.com/<your-username>/linux-shell-devops-projects.git cd linux-shell-devops-projects chmod +x **/*.sh` 

Navigate into any project folder and run the script:

`cd log-monitor
./log_monitor.sh --help` 

Each script has:

-   Help menu
    
-   Config file support
    
-   Safe defaults
    
----------

## 👤 Author

**Harini Muruganantham**  
DevOps | Linux | Shell Scripting | Cloud Automation