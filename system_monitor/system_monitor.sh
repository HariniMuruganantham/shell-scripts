#!/bin/bash

###############################################################################
# System & Container Monitor Script
# Automated metrics collection with report generation
# Monitors system resources and container performance
###############################################################################

# Configuration
CONFIG_FILE="${HOME}/.sysmonitor.conf"
METRICS_DIR="${HOME}/.sysmonitor/metrics"
REPORTS_DIR="${HOME}/.sysmonitor/reports"
HISTORY_DAYS=30
COLLECTION_INTERVAL=60
DOCKER_ENABLED=true
KUBERNETES_ENABLED=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

###############################################################################
# UTILITY FUNCTIONS
###############################################################################

log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO) echo -e "${GREEN}[INFO]${NC} [$timestamp] $message" ;;
        WARN) echo -e "${YELLOW}[WARN]${NC} [$timestamp] $message" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} [$timestamp] $message" ;;
        DEBUG) echo -e "${BLUE}[DEBUG]${NC} [$timestamp] $message" ;;
    esac
}

# Initialize directories
init_dirs() {
    mkdir -p "$export_dir"
    log_message INFO "Exporting metrics to $export_dir..."
    
    cp -r "$METRICS_DIR"/* "$export_dir/" 2>/dev/null
    cp -r "$REPORTS_DIR"/* "$export_dir/" 2>/dev/null
    
    log_message INFO "Export completed to $export_dir"
}

###############################################################################
# MAIN
###############################################################################

main() {
    case "${1:-}" in
        --init)
            create_config
            init_dirs
            ;;
        --collect)
            load_config
            init_dirs
            collect_all_metrics
            ;;
        --monitor)
            load_config
            init_dirs
            monitoring_loop
            ;;
        --dashboard)
            load_config
            init_dirs
            while true; do
                display_dashboard
                sleep 2
            done
            ;;
        --report)
            load_config
            init_dirs
            generate_system_report "${2:-daily}"
            ;;
        --docker-stats)
            show_docker_stats
            ;;
        --cleanup)
            load_config
            cleanup_old_metrics
            ;;
        --export)
            load_config
            export_metrics "$2"
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            main "$@"
            ;;
        -h|--help|*)
            usage
            ;;
    esac
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi -p "$METRICS_DIR"/{system,docker,kubernetes}
    mkdir -p "$REPORTS_DIR"/{daily,weekly,monthly}
    log_message INFO "Initialized directories"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_message INFO "Configuration loaded from $CONFIG_FILE"
    else
        log_message WARN "No configuration file found, using defaults"
    fi
}

# Create default configuration
create_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# System Monitor Configuration

# Directories
METRICS_DIR="${HOME}/.sysmonitor/metrics"
REPORTS_DIR="${HOME}/.sysmonitor/reports"

# Collection settings
COLLECTION_INTERVAL=60  # seconds
HISTORY_DAYS=30         # days to keep metrics

# Container monitoring
DOCKER_ENABLED=true
KUBERNETES_ENABLED=false

# Alerting thresholds
CPU_THRESHOLD=80        # percent
MEMORY_THRESHOLD=85     # percent
DISK_THRESHOLD=90       # percent
LOAD_THRESHOLD=4.0      # load average

# Report settings
REPORT_EMAIL=""         # email for reports
GENERATE_DAILY=true
GENERATE_WEEKLY=true
GENERATE_MONTHLY=true
EOF
    log_message INFO "Created configuration file: $CONFIG_FILE"
}

# Get timestamp for metrics
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Convert bytes to human readable
bytes_to_human() {
    local bytes=$1
    awk "BEGIN {printf \"%.2f\", $bytes/1073741824}" 2>/dev/null || echo "0"
}

###############################################################################
# SYSTEM METRICS COLLECTION
###############################################################################

collect_cpu_metrics() {
    local timestamp=$(get_timestamp)
    local metrics_file="$METRICS_DIR/system/cpu_$(date +%Y%m%d).csv"
    
    # Create header if file doesn't exist
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,usage_percent,load_1m,load_5m,load_15m,processes,running,blocked" > "$metrics_file"
    fi
    
    # Get CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    
    # Get load average
    local load=$(cat /proc/loadavg 2>/dev/null || uptime | awk -F'load average:' '{print $2}')
    local load_1m=$(echo "$load" | awk '{print $1}' | tr -d ',')
    local load_5m=$(echo "$load" | awk '{print $2}' | tr -d ',')
    local load_15m=$(echo "$load" | awk '{print $3}' | tr -d ',')
    
    # Get process counts
    local total_proc=$(ps aux | wc -l)
    local running=$(ps aux | awk '$8=="R" || $8=="R+" {print}' | wc -l)
    local blocked=$(ps aux | awk '$8=="D" || $8=="D+" {print}' | wc -l)
    
    echo "$timestamp,$cpu_usage,$load_1m,$load_5m,$load_15m,$total_proc,$running,$blocked" >> "$metrics_file"
    
    echo "$cpu_usage"
}

collect_memory_metrics() {
    local timestamp=$(get_timestamp)
    local metrics_file="$METRICS_DIR/system/memory_$(date +%Y%m%d).csv"
    
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,total_gb,used_gb,free_gb,available_gb,used_percent,swap_total_gb,swap_used_gb,swap_free_gb" > "$metrics_file"
    fi
    
    if [ -f /proc/meminfo ]; then
        local total=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
        local free=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')
        local available=$(grep "MemAvailable:" /proc/meminfo | awk '{print $2}')
        local used=$((total - available))
        local used_percent=$((used * 100 / total))
        
        local swap_total=$(grep "SwapTotal:" /proc/meminfo | awk '{print $2}')
        local swap_free=$(grep "SwapFree:" /proc/meminfo | awk '{print $2}')
        local swap_used=$((swap_total - swap_free))
        
        local total_gb=$(bytes_to_human $((total * 1024)))
        local used_gb=$(bytes_to_human $((used * 1024)))
        local free_gb=$(bytes_to_human $((free * 1024)))
        local available_gb=$(bytes_to_human $((available * 1024)))
        local swap_total_gb=$(bytes_to_human $((swap_total * 1024)))
        local swap_used_gb=$(bytes_to_human $((swap_used * 1024)))
        local swap_free_gb=$(bytes_to_human $((swap_free * 1024)))
        
        echo "$timestamp,$total_gb,$used_gb,$free_gb,$available_gb,$used_percent,$swap_total_gb,$swap_used_gb,$swap_free_gb" >> "$metrics_file"
        
        echo "$used_percent"
    fi
}

collect_disk_metrics() {
    local timestamp=$(get_timestamp)
    local metrics_file="$METRICS_DIR/system/disk_$(date +%Y%m%d).csv"
    
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,filesystem,mount,total_gb,used_gb,available_gb,used_percent" > "$metrics_file"
    fi
    
    df -BG | grep -E "^/dev/" | while read line; do
        local filesystem=$(echo "$line" | awk '{print $1}')
        local total=$(echo "$line" | awk '{print $2}' | tr -d 'G')
        local used=$(echo "$line" | awk '{print $3}' | tr -d 'G')
        local available=$(echo "$line" | awk '{print $4}' | tr -d 'G')
        local percent=$(echo "$line" | awk '{print $5}' | tr -d '%')
        local mount=$(echo "$line" | awk '{print $6}')
        
        echo "$timestamp,$filesystem,$mount,$total,$used,$available,$percent" >> "$metrics_file"
    done
    
    df -BG / | tail -1 | awk '{print $5}' | tr -d '%'
}

collect_network_metrics() {
    local timestamp=$(get_timestamp)
    local metrics_file="$METRICS_DIR/system/network_$(date +%Y%m%d).csv"
    
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,interface,rx_bytes_gb,tx_bytes_gb,rx_packets,tx_packets,rx_errors,tx_errors" > "$metrics_file"
    fi
    
    for iface in $(ls /sys/class/net/ | grep -v "^lo$"); do
        if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
            local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes)
            local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes)
            local rx_packets=$(cat /sys/class/net/$iface/statistics/rx_packets)
            local tx_packets=$(cat /sys/class/net/$iface/statistics/tx_packets)
            local rx_errors=$(cat /sys/class/net/$iface/statistics/rx_errors)
            local tx_errors=$(cat /sys/class/net/$iface/statistics/tx_errors)
            
            local rx_gb=$(bytes_to_human $rx_bytes)
            local tx_gb=$(bytes_to_human $tx_bytes)
            
            echo "$timestamp,$iface,$rx_gb,$tx_gb,$rx_packets,$tx_packets,$rx_errors,$tx_errors" >> "$metrics_file"
        fi
    done
}

###############################################################################
# DOCKER CONTAINER METRICS
###############################################################################

collect_docker_metrics() {
    if [ "$DOCKER_ENABLED" != true ] || ! command -v docker &> /dev/null; then
        return
    fi
    
    local timestamp=$(get_timestamp)
    local metrics_file="$METRICS_DIR/docker/containers_$(date +%Y%m%d).csv"
    
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,container_id,name,status,cpu_percent,memory_usage_mb,memory_limit_mb,memory_percent,network_rx_mb,network_tx_mb,block_read_mb,block_write_mb" > "$metrics_file"
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log_message WARN "Docker daemon not running"
        return
    fi
    
    docker stats --no-stream --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null | tail -n +2 | while read line; do
        local container_id=$(echo "$line" | awk '{print $1}')
        local name=$(echo "$line" | awk '{print $2}')
        local cpu=$(echo "$line" | awk '{print $3}' | tr -d '%')
        local mem_usage=$(echo "$line" | awk '{print $4}' | cut -d'/' -f1 | tr -d 'MiB')
        local mem_limit=$(echo "$line" | awk '{print $4}' | cut -d'/' -f2 | tr -d 'MiB')
        local mem_percent=$(echo "$line" | awk '{print $5}' | tr -d '%')
        local net_rx=$(echo "$line" | awk '{print $6}' | cut -d'/' -f1 | tr -d 'MB')
        local net_tx=$(echo "$line" | awk '{print $6}' | cut -d'/' -f2 | tr -d 'MB')
        local block_read=$(echo "$line" | awk '{print $7}' | cut -d'/' -f1 | tr -d 'MB')
        local block_write=$(echo "$line" | awk '{print $7}' | cut -d'/' -f2 | tr -d 'MB')
        
        # Get container status
        local status=$(docker inspect --format='{{.State.Status}}' "$container_id" 2>/dev/null)
        
        echo "$timestamp,$container_id,$name,$status,$cpu,$mem_usage,$mem_limit,$mem_percent,$net_rx,$net_tx,$block_read,$block_write" >> "$metrics_file"
    done
}

get_docker_container_summary() {
    if [ "$DOCKER_ENABLED" != true ] || ! command -v docker &> /dev/null; then
        echo "Docker not available"
        return
    fi
    
    if ! docker info &> /dev/null; then
        echo "Docker daemon not running"
        return
    fi
    
    local total=$(docker ps -a -q | wc -l)
    local running=$(docker ps -q | wc -l)
    local stopped=$(docker ps -a -q -f status=exited | wc -l)
    
    echo "Total: $total | Running: $running | Stopped: $stopped"
}

###############################################################################
# KUBERNETES METRICS (if enabled)
###############################################################################

collect_k8s_metrics() {
    if [ "$KUBERNETES_ENABLED" != true ] || ! command -v kubectl &> /dev/null; then
        return
    fi
    
    local timestamp=$(get_timestamp)
    local metrics_file="$METRICS_DIR/kubernetes/pods_$(date +%Y%m%d).csv"
    
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,namespace,pod_name,status,cpu_usage,memory_usage" > "$metrics_file"
    fi
    
    kubectl get pods --all-namespaces --no-headers 2>/dev/null | while read line; do
        local namespace=$(echo "$line" | awk '{print $1}')
        local pod=$(echo "$line" | awk '{print $2}')
        local status=$(echo "$line" | awk '{print $4}')
        
        echo "$timestamp,$namespace,$pod,$status,0,0" >> "$metrics_file"
    done
}

###############################################################################
# REPORT GENERATION
###############################################################################

generate_system_report() {
    local report_type=$1  # daily, weekly, monthly
    local timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
    local report_file="$REPORTS_DIR/$report_type/system_report_$timestamp.html"
    
    log_message INFO "Generating $report_type system report..."
    
    # Calculate date range
    case $report_type in
        daily)
            local start_date=$(date -d "1 day ago" '+%Y-%m-%d' 2>/dev/null || date -v-1d '+%Y-%m-%d')
            ;;
        weekly)
            local start_date=$(date -d "7 days ago" '+%Y-%m-%d' 2>/dev/null || date -v-7d '+%Y-%m-%d')
            ;;
        monthly)
            local start_date=$(date -d "30 days ago" '+%Y-%m-%d' 2>/dev/null || date -v-30d '+%Y-%m-%d')
            ;;
    esac
    
    # Get latest metrics
    local cpu_usage=$(tail -1 "$METRICS_DIR/system/cpu_$(date +%Y%m%d).csv" 2>/dev/null | cut -d',' -f2)
    local mem_usage=$(tail -1 "$METRICS_DIR/system/memory_$(date +%Y%m%d).csv" 2>/dev/null | cut -d',' -f6)
    local disk_usage=$(df -BG / | tail -1 | awk '{print $5}' | tr -d '%')
    local load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    
    # Calculate averages from metrics
    local cpu_avg=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}' "$METRICS_DIR/system/cpu_$(date +%Y%m%d).csv" 2>/dev/null)
    local mem_avg=$(awk -F',' 'NR>1 {sum+=$6; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}' "$METRICS_DIR/system/memory_$(date +%Y%m%d).csv" 2>/dev/null)
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>System Monitor Report - $(echo $report_type | tr '[:lower:]' '[:upper:]')</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 10px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); overflow: hidden; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { font-size: 1.1em; opacity: 0.9; }
        .content { padding: 30px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .metric-card { background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); padding: 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: transform 0.3s; }
        .metric-card:hover { transform: translateY(-5px); }
        .metric-card h3 { color: #667eea; margin-bottom: 15px; font-size: 1.1em; }
        .metric-value { font-size: 2.5em; font-weight: bold; color: #2c3e50; margin: 10px 0; }
        .metric-label { color: #7f8c8d; font-size: 0.9em; }
        .status-good { color: #27ae60; }
        .status-warning { color: #f39c12; }
        .status-critical { color: #e74c3c; }
        .progress-bar { background: #ecf0f1; border-radius: 10px; height: 20px; overflow: hidden; margin: 10px 0; }
        .progress-fill { height: 100%; transition: width 0.3s; }
        .section { margin: 30px 0; }
        .section h2 { color: #2c3e50; border-bottom: 3px solid #667eea; padding-bottom: 10px; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ecf0f1; }
        th { background: #667eea; color: white; font-weight: 600; }
        tr:hover { background: #f8f9fa; }
        .footer { background: #2c3e50; color: white; padding: 20px; text-align: center; }
        .chart-placeholder { background: #f8f9fa; border: 2px dashed #bdc3c7; border-radius: 10px; padding: 40px; text-align: center; color: #7f8c8d; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 System Monitor Report</h1>
            <p>$(echo $report_type | tr '[:lower:]' '[:upper:]') REPORT - Generated on $(date '+%B %d, %Y at %H:%M:%S')</p>
            <p>Hostname: $(hostname) | Period: $start_date to $(date '+%Y-%m-%d')</p>
        </div>
        
        <div class="content">
            <div class="summary">
                <div class="metric-card">
                    <h3>🖥️ CPU Usage</h3>
                    <div class="metric-value $([ ${cpu_usage%.*} -gt 80 ] && echo "status-critical" || [ ${cpu_usage%.*} -gt 60 ] && echo "status-warning" || echo "status-good")">${cpu_usage}%</div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: ${cpu_usage}%; background: $([ ${cpu_usage%.*} -gt 80 ] && echo "#e74c3c" || [ ${cpu_usage%.*} -gt 60 ] && echo "#f39c12" || echo "#27ae60");"></div>
                    </div>
                    <div class="metric-label">Average: ${cpu_avg}%</div>
                    <div class="metric-label">Load: $load_avg</div>
                </div>
                
                <div class="metric-card">
                    <h3>💾 Memory Usage</h3>
                    <div class="metric-value $([ ${mem_usage%.*} -gt 85 ] && echo "status-critical" || [ ${mem_usage%.*} -gt 70 ] && echo "status-warning" || echo "status-good")">${mem_usage}%</div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: ${mem_usage}%; background: $([ ${mem_usage%.*} -gt 85 ] && echo "#e74c3c" || [ ${mem_usage%.*} -gt 70 ] && echo "#f39c12" || echo "#27ae60");"></div>
                    </div>
                    <div class="metric-label">Average: ${mem_avg}%</div>
                </div>
                
                <div class="metric-card">
                    <h3>💿 Disk Usage</h3>
                    <div class="metric-value $([ ${disk_usage%.*} -gt 90 ] && echo "status-critical" || [ ${disk_usage%.*} -gt 75 ] && echo "status-warning" || echo "status-good")">${disk_usage}%</div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: ${disk_usage}%; background: $([ ${disk_usage%.*} -gt 90 ] && echo "#e74c3c" || [ ${disk_usage%.*} -gt 75 ] && echo "#f39c12" || echo "#27ae60");"></div>
                    </div>
                    <div class="metric-label">Root filesystem</div>
                </div>
                
                <div class="metric-card">
                    <h3>🐳 Containers</h3>
                    <div class="metric-value status-good">$(get_docker_container_summary)</div>
                    <div class="metric-label">Docker containers status</div>
                </div>
            </div>
            
            <div class="section">
                <h2>📈 Resource Trends</h2>
                <div class="chart-placeholder">
                    <h3>Time Series Charts</h3>
                    <p>CPU, Memory, and Disk usage trends over time</p>
                    <p style="margin-top: 10px; font-size: 0.9em;">Metrics data available in: $METRICS_DIR</p>
                </div>
            </div>
            
            <div class="section">
                <h2>🔝 Top Processes</h2>
                <table>
                    <tr>
                        <th>PID</th>
                        <th>User</th>
                        <th>CPU %</th>
                        <th>Memory %</th>
                        <th>Command</th>
                    </tr>
EOF

    # Add top 10 processes
    ps aux --sort=-%cpu | head -11 | tail -10 | while read line; do
        local user=$(echo "$line" | awk '{print $1}')
        local pid=$(echo "$line" | awk '{print $2}')
        local cpu=$(echo "$line" | awk '{print $3}')
        local mem=$(echo "$line" | awk '{print $4}')
        local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}' | cut -c1-60)
        
        echo "<tr><td>$pid</td><td>$user</td><td>$cpu</td><td>$mem</td><td>$cmd</td></tr>" >> "$report_file"
    done

    cat >> "$report_file" << EOF
                </table>
            </div>
            
            <div class="section">
                <h2>🌐 Network Statistics</h2>
                <table>
                    <tr>
                        <th>Interface</th>
                        <th>RX Data</th>
                        <th>TX Data</th>
                        <th>RX Packets</th>
                        <th>TX Packets</th>
                        <th>Errors</th>
                    </tr>
EOF

    # Add network statistics
    if [ -f "$METRICS_DIR/system/network_$(date +%Y%m%d).csv" ]; then
        tail -5 "$METRICS_DIR/system/network_$(date +%Y%m%d).csv" | grep -v "timestamp" | while IFS=',' read timestamp iface rx_gb tx_gb rx_packets tx_packets rx_errors tx_errors; do
            local total_errors=$((rx_errors + tx_errors))
            echo "<tr><td>$iface</td><td>${rx_gb}GB</td><td>${tx_gb}GB</td><td>$rx_packets</td><td>$tx_packets</td><td>$total_errors</td></tr>" >> "$report_file"
        done
    fi

    cat >> "$report_file" << EOF
                </table>
            </div>
        </div>
        
        <div class="footer">
            <p>System Monitor Script v1.0 | Generated: $(date)</p>
            <p>Metrics Directory: $METRICS_DIR</p>
            <p>Reports Directory: $REPORTS_DIR</p>
        </div>
    </div>
</body>
</html>
EOF

    log_message INFO "Report generated: $report_file"
    echo "$report_file"
}

###############################################################################
# MAIN COLLECTION LOOP
###############################################################################

collect_all_metrics() {
    log_message INFO "Collecting system metrics..."
    
    local cpu=$(collect_cpu_metrics)
    local mem=$(collect_memory_metrics)
    local disk=$(collect_disk_metrics)
    collect_network_metrics
    
    if [ "$DOCKER_ENABLED" = true ]; then
        collect_docker_metrics
    fi
    
    if [ "$KUBERNETES_ENABLED" = true ]; then
        collect_k8s_metrics
    fi
    
    log_message INFO "Metrics collected - CPU: ${cpu}%, Memory: ${mem}%, Disk: ${disk}%"
}

monitoring_loop() {
    log_message INFO "Starting monitoring loop (interval: ${COLLECTION_INTERVAL}s)"
    
    while true; do
        collect_all_metrics
        sleep "$COLLECTION_INTERVAL"
    done
}

###############################################################################
# CLI INTERFACE
###############################################################################

display_dashboard() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                   SYSTEM & CONTAINER MONITOR                              ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # System metrics
    echo -e "${GREEN}System Resources:${NC}"
    local cpu=$(collect_cpu_metrics)
    local mem=$(collect_memory_metrics)
    local disk=$(collect_disk_metrics)
    local load=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    
    printf "  CPU Usage:    %s%%\n" "$cpu"
    printf "  Memory Usage: %s%%\n" "$mem"
    printf "  Disk Usage:   %s%%\n" "$disk"
    printf "  Load Average: %s\n" "$load"
    
    # Docker containers
    if [ "$DOCKER_ENABLED" = true ] && command -v docker &> /dev/null; then
        echo ""
        echo -e "${BLUE}Docker Containers:${NC}"
        echo "  $(get_docker_container_summary)"
    fi
    
    echo ""
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring${NC}"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

System and Container Monitor - Automated metrics collection and reporting

OPTIONS:
    -h, --help              Show this help message
    --init                  Initialize configuration and directories
    --collect               Collect metrics once and exit
    --monitor               Start continuous monitoring
    --dashboard             Show live dashboard
    --report TYPE           Generate report (daily|weekly|monthly)
    --docker-stats          Show Docker container statistics
    --cleanup               Clean old metrics (older than HISTORY_DAYS)
    --export DIR            Export all metrics to directory
    --config FILE           Use custom configuration file

EXAMPLES:
    # Initialize
    $0 --init

    # Collect metrics once
    $0 --collect

    # Start monitoring
    $0 --monitor

    # Generate daily report
    $0 --report daily

    # Show live dashboard
    $0 --dashboard

    # Clean old metrics
    $0 --cleanup

EOF
}

cleanup_old_metrics() {
    log_message INFO "Cleaning metrics older than $HISTORY_DAYS days..."
    
    find "$METRICS_DIR" -name "*.csv" -mtime +$HISTORY_DAYS -delete
    find "$REPORTS_DIR" -name "*.html" -mtime +$HISTORY_DAYS -delete
    
    log_message INFO "Cleanup completed"
}

show_docker_stats() {
    if ! command -v docker &> /dev/null; then
        log_message ERROR "Docker not installed"
        return 1
    fi
    
    echo -e "${CYAN}Docker Container Statistics${NC}\n"
    docker stats --no-stream
}

export_metrics() {
    local export_dir=$1
    
    if [ -z "$export_dir" ]; then
        log_message ERROR "Export directory not specified"
        return 1
    fi
    
    mkdir