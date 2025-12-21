
# 📊 System & Container Monitor Script (Bash)

  

  

  

  

  

A **comprehensive system and container monitoring solution** written entirely in **Bash**, designed to collect metrics, track trends, and generate **professional HTML reports** for Linux servers, Docker hosts, and optional Kubernetes environments.

Built with **DevOps automation, observability, and reporting** in mind.

----------

## 🎯 Purpose

This script provides:

-   Automated **system resource monitoring**
    
-   **Container performance visibility**
    
-   Long-term **metrics retention**
    
-   **Daily / Weekly / Monthly** reporting
    
-   A **live terminal dashboard**
    
-   Zero external dependencies beyond standard Linux tools
    

Ideal for:

-   EC2 / VM monitoring
    
-   DevOps learning projects
    
-   Lightweight observability without Prometheus
    
-   Interview & portfolio demonstrations
    

----------

## ✨ Key Features

### 🖥️ System Monitoring

-   CPU usage & load average
    
-   Memory & swap utilization
    
-   Disk usage per filesystem
    
-   Network RX/TX statistics
    
-   Process analysis (top consumers)
    

### 🐳 Container Monitoring

-   Docker container CPU & memory usage
    
-   Network and block I/O
    
-   Container status (running/stopped)
    
-   Per-container historical CSV metrics
    

### ☸️ Kubernetes (Optional)

-   Pod and namespace visibility (kubectl-based)
    
-   Extendable for metrics-server integration
    

### 📈 Reporting & Analytics

-   Auto-generated **HTML reports**
    
-   Clean UI with progress bars & health indicators
    
-   Daily / Weekly / Monthly summaries
    
-   Historical averages & trend placeholders
    

### 🖥️ CLI Dashboard

-   Live updating terminal dashboard
    
-   Real-time CPU, memory, disk & container view
    
-   Clean ASCII UI for monitoring sessions
    

----------

## 🧱 Architecture Overview

```text
~/.sysmonitor/
├── metrics/
│   ├── system/
│   │   ├── cpu_YYYYMMDD.csv
│   │   ├── memory_YYYYMMDD.csv
│   │   ├── disk_YYYYMMDD.csv
│   │   └── network_YYYYMMDD.csv
│   ├── docker/
│   │   └── containers_YYYYMMDD.csv
│   └── kubernetes/
│       └── pods_YYYYMMDD.csv
│
├── reports/
│   ├── daily/
│   ├── weekly/
│   └── monthly/
│
└── .sysmonitor.conf

----------

## 🛠️ Requirements

-   Linux (Ubuntu, Amazon Linux, Debian, RHEL)
    
-   Bash 4.x+
    
-   Core utilities:
    
    -   `top`, `ps`, `df`, `awk`, `sed`
        
-   Optional:
    
    -   Docker CLI (`docker`)
        
    -   Kubernetes CLI (`kubectl`)
        

No external monitoring stack required.

----------

## ⚙️ Installation

`git clone https://github.com/<your-username>/system-container-monitor.git 
cd system-container-monitor chmod +x sysmonitor.sh` 

----------

## 🔧 Configuration

### Initialize Configuration

`./sysmonitor.sh --init` 

This creates:

`~/.sysmonitor.conf
~/.sysmonitor/metrics
~/.sysmonitor/reports` 

### Example Config

`COLLECTION_INTERVAL=60
HISTORY_DAYS=30

DOCKER_ENABLED=true KUBERNETES_ENABLED=false CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
LOAD_THRESHOLD=4.0` 

----------

## ▶️ Usage

### Initialize

`./sysmonitor.sh --init` 

### Collect Metrics Once

`./sysmonitor.sh --collect` 

### Continuous Monitoring

`./sysmonitor.sh --monitor` 

### Live Dashboard

`./sysmonitor.sh --dashboard` 

### Generate Reports

`./sysmonitor.sh --report daily
./sysmonitor.sh --report weekly
./sysmonitor.sh --report monthly` 

### Docker Container Stats

`./sysmonitor.sh --docker-stats` 

### Cleanup Old Data

`./sysmonitor.sh --cleanup` 

### Export Metrics

`./sysmonitor.sh --export /backup/sysmetrics` 

----------

## 📊 Reports

Generated reports include:

-   CPU, Memory, Disk health indicators
    
-   Load averages
    
-   Docker container summary
    
-   Top resource-consuming processes
    
-   Network statistics
    
-   Clean, responsive HTML layout
    

Reports are stored in:

`~/.sysmonitor/reports/` 

Open directly in a browser.

----------

## 🔐 Reliability & Safety

-   CSV-based metrics for easy parsing
    
-   No root privileges required (except Docker access)
    
-   Graceful handling of missing tools
    
-   Safe defaults with configurable thresholds
    
-   Works on minimal cloud instances
    

----------

## 👤 Author

**Harini Muruganantham**  
DevOps | Linux | Shell Scripting | Cloud Automation