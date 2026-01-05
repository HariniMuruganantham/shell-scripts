# 🖥️ Comprehensive System Information Script

A production-ready **Bash automation script** that collects detailed system information across **hardware, OS, CPU, memory, disk, network, users, processes, and devices**.

Designed for **Linux and macOS**, this script produces a **clean, color-coded, and human-readable system diagnostic report** in a single execution.

---

## 🚀 Overview

This project provides a comprehensive system inspection utility useful for:

- DevOps Engineers
- Linux/System Administrators
- Cloud Engineers
- Infrastructure troubleshooting
- Server audits
- Learning Linux internals
- Portfolio and interview demonstrations

The script is modular, readable, and follows **DevOps scripting best practices**.

---

## ✨ Key Features

- Cross-platform support (**Linux & macOS**)
- OS, kernel, and architecture detection
- Detailed CPU analysis (cores, load, virtualization)
- Memory & swap usage with percentages
- Disk usage and I/O statistics
- Network inspection (IP, MAC, RX/TX, DNS, gateway)
- User and process analysis
- Hardware discovery (PCI, USB, lshw)
- Color-coded, section-based output
- Human-readable sizes (KB / MB / GB)

---

## 🛠️ Tech Stack

- **Language:** Bash  
- **Platforms:** Linux, macOS  
- **Utilities Used:**  
  `awk`, `sed`, `grep`, `ps`, `df`, `ip`, `lscpu`, `iostat`, `lshw`, `sysctl`

---

## 📂 Information Collected

### 🖥️ System Information
- Hostname
- OS type & distribution
- Kernel version
- Architecture
- Uptime
- Date & timezone

### ⚙️ CPU Information
- CPU model
- Physical & logical cores
- CPU frequency
- Load average
- Virtualization support

### 🧠 Memory Information
- Total, used, and free memory
- Memory usage percentage
- Swap usage details

### 💾 Disk Information
- Mounted devices
- Disk usage per mount
- Available space
- Disk I/O statistics (if available)

### 🌐 Network Information
- Network interfaces
- IPv4 / IPv6 addresses
- MAC addresses
- RX / TX statistics
- Default gateway
- DNS servers

### 👤 User & Process Information
- Current user details
- Logged-in users
- Total process count
- Top CPU-consuming processes
- Top memory-consuming processes

### 🧩 Hardware Information
- PCI devices
- USB devices
- Detailed hardware info (sudo)
- System model (macOS)

---

## ▶️ Usage

### 1️⃣ Make the script executable
```bash
chmod +x system_info.sh

2️⃣ Run the script
bash
Copy code
./system_info.sh
3️⃣ (Optional) Run with sudo for detailed hardware info
bash
Copy code
sudo ./system_info.sh

---

🎯 Use Cases
Server health checks

Linux & cloud VM inspection

Incident troubleshooting

Infrastructure audits

Learning Bash & Linux internals

DevOps portfolio demonstration

---

🧑‍💻 Author
Harini Muruganantham
DevOps | Linux | Shell Scripting | Cloud Automation

