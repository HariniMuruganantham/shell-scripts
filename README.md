
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
├── typing-game/
│   ├── typing_game.sh
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
    

----------

### 5️⃣ Shell Typing Game (Bash)

📄 **File:** `typing-game/typing_game.sh`

**Purpose:**
An interactive terminal-based typing practice game built using Bash shell scripting.
The project focuses on user input handling, timing logic, accuracy calculation, and signal handling in Linux.

**Key Features:**

Colored welcome interface with borders

Difficulty selection (Easy / Medium / Hard)

Random word typing with time limits

Accuracy calculation based on user input

Graceful exit using signal handling (Ctrl + C)

Uses Linux utilities such as shuf, awk, and read -t

Clean, menu-driven terminal UI

**Use Case:**
Linux shell scripting practice, beginner DevOps learning, understanding interactive Bash programs, and improving typing accuracy in terminal environments.
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

## 👩‍💻 Author

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Harini-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/harini-muruganantham)
[![GitHub](https://img.shields.io/badge/GitHub-Harini-black?style=flat-square&logo=github)](https://github.com/HariniMuruganantham)
[![Substack](https://img.shields.io/badge/Substack-Harini-orange?style=flat-square&logo=substack)](https://substack.com/@harinimuruganantham)

**Harini Muruganantham**  
DevOps Engineer | AWS | 

