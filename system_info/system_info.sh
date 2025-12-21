#!/bin/bash

###############################################################################
# project name: Comprehensive System Information Script
# Purpose: Collects detailed information about system hardware, OS, network, and resources
# Author: Harini Muruganantham
# Date: 21st december 2025
# Version: 1.0
###############################################################################

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${CYAN}===============================================================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${CYAN}===============================================================================${NC}"
}

# Function to print key-value pairs
print_info() {
    printf "${YELLOW}%-30s${NC}: %s\n" "$1" "$2"
}

# Function to convert bytes to human readable format
bytes_to_human() {
    local bytes=$1
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1024}")KB"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}")MB"
    else
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1073741824}")GB"
    fi
}

# Detect OS type
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macOS"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        OS_TYPE="FreeBSD"
    else
        OS_TYPE="Unknown"
    fi
}

###############################################################################
# SYSTEM INFORMATION
###############################################################################
get_system_info() {
    print_header "SYSTEM INFORMATION"
    
    print_info "Hostname" "$(hostname)"
    print_info "Operating System" "$OS_TYPE"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            print_info "Distribution" "$NAME $VERSION"
        fi
        print_info "Kernel" "$(uname -r)"
        print_info "Architecture" "$(uname -m)"
    elif [ "$OS_TYPE" == "macOS" ]; then
        print_info "macOS Version" "$(sw_vers -productVersion)"
        print_info "Build" "$(sw_vers -buildVersion)"
        print_info "Kernel" "$(uname -r)"
        print_info "Architecture" "$(uname -m)"
    fi
    
    print_info "Kernel Name" "$(uname -s)"
    print_info "Uptime" "$(uptime | sed 's/.*up \([^,]*\), .*/\1/')"
    print_info "Current Date/Time" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    
    if [ -f /proc/version ]; then
        print_info "Kernel Version" "$(cat /proc/version | cut -d' ' -f1-3)"
    fi
}

###############################################################################
# CPU INFORMATION
###############################################################################
get_cpu_info() {
    print_header "CPU INFORMATION"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        if [ -f /proc/cpuinfo ]; then
            CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
            CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
            CPU_PHYSICAL=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
            
            print_info "CPU Model" "$CPU_MODEL"
            print_info "Physical CPUs" "$CPU_PHYSICAL"
            print_info "CPU Cores" "$CPU_CORES"
            
            if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
                FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
                FREQ_MHZ=$(awk "BEGIN {printf \"%.2f\", $FREQ/1000}")
                print_info "Current Frequency" "${FREQ_MHZ}MHz"
            fi
        fi
        
        if command -v lscpu &> /dev/null; then
            print_info "Architecture" "$(lscpu | grep "Architecture:" | awk '{print $2}')"
            print_info "CPU MHz" "$(lscpu | grep "CPU MHz:" | awk '{print $3}')"
            print_info "Virtualization" "$(lscpu | grep "Virtualization:" | awk '{print $2}')"
        fi
        
        # CPU Load
        if [ -f /proc/loadavg ]; then
            LOAD=$(cat /proc/loadavg | cut -d' ' -f1-3)
            print_info "Load Average (1,5,15)" "$LOAD"
        fi
        
    elif [ "$OS_TYPE" == "macOS" ]; then
        CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)
        CPU_CORES=$(sysctl -n hw.ncpu)
        CPU_PHYSICAL=$(sysctl -n hw.physicalcpu)
        
        print_info "CPU Model" "$CPU_MODEL"
        print_info "Physical CPUs" "$CPU_PHYSICAL"
        print_info "Logical CPUs" "$CPU_CORES"
        print_info "CPU Speed" "$(sysctl -n hw.cpufrequency | awk '{printf "%.2f GHz", $1/1000000000}')"
        print_info "Load Average" "$(uptime | awk -F'load averages:' '{print $2}')"
    fi
}

###############################################################################
# MEMORY INFORMATION
###############################################################################
get_memory_info() {
    print_header "MEMORY INFORMATION"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        if [ -f /proc/meminfo ]; then
            TOTAL_MEM=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
            FREE_MEM=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
            USED_MEM=$((TOTAL_MEM - FREE_MEM))
            
            TOTAL_MEM_MB=$((TOTAL_MEM / 1024))
            FREE_MEM_MB=$((FREE_MEM / 1024))
            USED_MEM_MB=$((USED_MEM / 1024))
            PERCENT=$((USED_MEM * 100 / TOTAL_MEM))
            
            print_info "Total Memory" "${TOTAL_MEM_MB}MB"
            print_info "Used Memory" "${USED_MEM_MB}MB"
            print_info "Free Memory" "${FREE_MEM_MB}MB"
            print_info "Memory Usage" "${PERCENT}%"
            
            # Swap Information
            TOTAL_SWAP=$(grep "SwapTotal:" /proc/meminfo | awk '{print $2}')
            FREE_SWAP=$(grep "SwapFree:" /proc/meminfo | awk '{print $2}')
            USED_SWAP=$((TOTAL_SWAP - FREE_SWAP))
            
            if [ "$TOTAL_SWAP" -gt 0 ]; then
                TOTAL_SWAP_MB=$((TOTAL_SWAP / 1024))
                USED_SWAP_MB=$((USED_SWAP / 1024))
                FREE_SWAP_MB=$((FREE_SWAP / 1024))
                SWAP_PERCENT=$((USED_SWAP * 100 / TOTAL_SWAP))
                
                print_info "Total Swap" "${TOTAL_SWAP_MB}MB"
                print_info "Used Swap" "${USED_SWAP_MB}MB"
                print_info "Free Swap" "${FREE_SWAP_MB}MB"
                print_info "Swap Usage" "${SWAP_PERCENT}%"
            else
                print_info "Swap" "Not configured"
            fi
        fi
        
    elif [ "$OS_TYPE" == "macOS" ]; then
        TOTAL_MEM=$(sysctl -n hw.memsize)
        TOTAL_MEM_GB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_MEM/1073741824}")
        
        print_info "Total Memory" "${TOTAL_MEM_GB}GB"
        
        if command -v vm_stat &> /dev/null; then
            VM_STAT=$(vm_stat)
            PAGE_SIZE=$(vm_stat | grep "page size" | awk '{print $8}')
            PAGES_FREE=$(echo "$VM_STAT" | grep "Pages free" | awk '{print $3}' | tr -d '.')
            PAGES_ACTIVE=$(echo "$VM_STAT" | grep "Pages active" | awk '{print $3}' | tr -d '.')
            PAGES_INACTIVE=$(echo "$VM_STAT" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
            PAGES_WIRED=$(echo "$VM_STAT" | grep "Pages wired" | awk '{print $4}' | tr -d '.')
            
            FREE_MEM=$((PAGES_FREE * PAGE_SIZE / 1048576))
            USED_MEM=$(((PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED) * PAGE_SIZE / 1048576))
            
            print_info "Used Memory" "${USED_MEM}MB"
            print_info "Free Memory" "${FREE_MEM}MB"
        fi
    fi
}

###############################################################################
# DISK INFORMATION
###############################################################################
get_disk_info() {
    print_header "DISK INFORMATION"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        df -h | grep -E "^/dev/" | while read line; do
            DEVICE=$(echo "$line" | awk '{print $1}')
            SIZE=$(echo "$line" | awk '{print $2}')
            USED=$(echo "$line" | awk '{print $3}')
            AVAIL=$(echo "$line" | awk '{print $4}')
            PERCENT=$(echo "$line" | awk '{print $5}')
            MOUNT=$(echo "$line" | awk '{print $6}')
            
            echo -e "\n${BLUE}Device: $DEVICE${NC}"
            print_info "  Mount Point" "$MOUNT"
            print_info "  Total Size" "$SIZE"
            print_info "  Used" "$USED"
            print_info "  Available" "$AVAIL"
            print_info "  Usage" "$PERCENT"
        done
        
        # Disk I/O statistics
        if command -v iostat &> /dev/null; then
            echo -e "\n${BLUE}Disk I/O Statistics:${NC}"
            iostat -d | tail -n +3
        fi
        
    elif [ "$OS_TYPE" == "macOS" ]; then
        df -h | grep -E "^/dev/" | while read line; do
            DEVICE=$(echo "$line" | awk '{print $1}')
            SIZE=$(echo "$line" | awk '{print $2}')
            USED=$(echo "$line" | awk '{print $3}')
            AVAIL=$(echo "$line" | awk '{print $4}')
            PERCENT=$(echo "$line" | awk '{print $5}')
            MOUNT=$(echo "$line" | awk '{print $9}')
            
            echo -e "\n${BLUE}Device: $DEVICE${NC}"
            print_info "  Mount Point" "$MOUNT"
            print_info "  Total Size" "$SIZE"
            print_info "  Used" "$USED"
            print_info "  Available" "$AVAIL"
            print_info "  Usage" "$PERCENT"
        done
    fi
}

###############################################################################
# NETWORK INFORMATION
###############################################################################
get_network_info() {
    print_header "NETWORK INFORMATION"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        # Get all network interfaces
        for iface in $(ls /sys/class/net/); do
            if [ "$iface" != "lo" ]; then
                echo -e "\n${BLUE}Interface: $iface${NC}"
                
                # Get IP address
                IP=$(ip addr show "$iface" 2>/dev/null | grep "inet " | awk '{print $2}')
                if [ -n "$IP" ]; then
                    print_info "  IPv4 Address" "$IP"
                fi
                
                # Get IPv6 address
                IP6=$(ip addr show "$iface" 2>/dev/null | grep "inet6" | grep -v "fe80" | awk '{print $2}')
                if [ -n "$IP6" ]; then
                    print_info "  IPv6 Address" "$IP6"
                fi
                
                # Get MAC address
                MAC=$(cat /sys/class/net/"$iface"/address 2>/dev/null)
                if [ -n "$MAC" ]; then
                    print_info "  MAC Address" "$MAC"
                fi
                
                # Get interface status
                STATUS=$(cat /sys/class/net/"$iface"/operstate 2>/dev/null)
                if [ -n "$STATUS" ]; then
                    print_info "  Status" "$STATUS"
                fi
                
                # Get RX/TX statistics
                if [ -f /sys/class/net/"$iface"/statistics/rx_bytes ]; then
                    RX=$(cat /sys/class/net/"$iface"/statistics/rx_bytes)
                    TX=$(cat /sys/class/net/"$iface"/statistics/tx_bytes)
                    print_info "  Received" "$(bytes_to_human $RX)"
                    print_info "  Transmitted" "$(bytes_to_human $TX)"
                fi
            fi
        done
        
        # Get default gateway
        GATEWAY=$(ip route | grep default | awk '{print $3}')
        if [ -n "$GATEWAY" ]; then
            echo ""
            print_info "Default Gateway" "$GATEWAY"
        fi
        
        # Get DNS servers
        if [ -f /etc/resolv.conf ]; then
            DNS=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
            if [ -n "$DNS" ]; then
                print_info "DNS Servers" "$DNS"
            fi
        fi
        
    elif [ "$OS_TYPE" == "macOS" ]; then
        for iface in $(networksetup -listallhardwareports | grep "Device:" | awk '{print $2}'); do
            if [ "$iface" != "lo0" ]; then
                echo -e "\n${BLUE}Interface: $iface${NC}"
                
                # Get IP address
                IP=$(ifconfig "$iface" 2>/dev/null | grep "inet " | awk '{print $2}')
                if [ -n "$IP" ]; then
                    print_info "  IPv4 Address" "$IP"
                fi
                
                # Get MAC address
                MAC=$(ifconfig "$iface" 2>/dev/null | grep "ether" | awk '{print $2}')
                if [ -n "$MAC" ]; then
                    print_info "  MAC Address" "$MAC"
                fi
                
                # Get interface status
                STATUS=$(ifconfig "$iface" 2>/dev/null | grep "status:" | awk '{print $2}')
                if [ -n "$STATUS" ]; then
                    print_info "  Status" "$STATUS"
                fi
            fi
        done
        
        # Get default gateway
        GATEWAY=$(netstat -rn | grep default | awk '{print $2}' | head -1)
        if [ -n "$GATEWAY" ]; then
            echo ""
            print_info "Default Gateway" "$GATEWAY"
        fi
    fi
}

###############################################################################
# USER AND PROCESS INFORMATION
###############################################################################
get_user_process_info() {
    print_header "USER AND PROCESS INFORMATION"
    
    print_info "Current User" "$(whoami)"
    print_info "User ID" "$(id -u)"
    print_info "Group ID" "$(id -g)"
    print_info "Home Directory" "$HOME"
    print_info "Shell" "$SHELL"
    
    # Logged in users
    echo -e "\n${BLUE}Logged in Users:${NC}"
    who
    
    # Total processes
    if [ "$OS_TYPE" == "Linux" ]; then
        PROC_COUNT=$(ps aux | wc -l)
        print_info "Total Processes" "$PROC_COUNT"
    elif [ "$OS_TYPE" == "macOS" ]; then
        PROC_COUNT=$(ps aux | wc -l | tr -d ' ')
        print_info "Total Processes" "$PROC_COUNT"
    fi
    
    # Top 5 CPU consuming processes
    echo -e "\n${BLUE}Top 5 CPU Consuming Processes:${NC}"
    ps aux --sort=-%cpu 2>/dev/null | head -6 || ps aux | sort -rk 3 | head -6
    
    # Top 5 Memory consuming processes
    echo -e "\n${BLUE}Top 5 Memory Consuming Processes:${NC}"
    ps aux --sort=-%mem 2>/dev/null | head -6 || ps aux | sort -rk 4 | head -6
}

###############################################################################
# HARDWARE INFORMATION
###############################################################################
get_hardware_info() {
    print_header "HARDWARE INFORMATION"
    
    if [ "$OS_TYPE" == "Linux" ]; then
        # Using lshw if available
        if command -v lshw &> /dev/null; then
            if [ "$EUID" -eq 0 ]; then
                lshw -short
            else
                echo "Note: Run with sudo for detailed hardware information"
            fi
        fi
        
        # PCI devices
        if command -v lspci &> /dev/null; then
            echo -e "\n${BLUE}PCI Devices:${NC}"
            lspci | head -10
        fi
        
        # USB devices
        if command -v lsusb &> /dev/null; then
            echo -e "\n${BLUE}USB Devices:${NC}"
            lsusb
        fi
        
    elif [ "$OS_TYPE" == "macOS" ]; then
        print_info "Model" "$(sysctl -n hw.model)"
        print_info "Serial Number" "$(system_profiler SPHardwareDataType | grep "Serial Number" | awk '{print $4}')"
        print_info "Chipset" "$(sysctl -n machdep.cpu.brand_string)"
    fi
}

###############################################################################
# MAIN EXECUTION
###############################################################################
main() {
    clear
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║           COMPREHENSIVE SYSTEM INFORMATION REPORT                         ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    detect_os
    
    get_system_info
    get_cpu_info
    get_memory_info
    get_disk_info
    get_network_info
    get_user_process_info
    get_hardware_info
    
    echo -e "\n${CYAN}===============================================================================${NC}"
    echo -e "${GREEN}Report generated on: $(date)${NC}"
    echo -e "${CYAN}===============================================================================${NC}\n"
}

# Run the script
main