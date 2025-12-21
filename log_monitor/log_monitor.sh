#!/bin/bash

###############################################################################
# Real-time Log Monitor Script
# Monitors log files for HTTP 500 errors and sends email alerts
# Supports multiple log formats and configurable alert thresholds
###############################################################################

# Configuration
CONFIG_FILE="${HOME}/.logmonitor.conf"
STATE_FILE="/tmp/logmonitor_state.tmp"
LOCK_FILE="/var/lock/logmonitor.lock"

# Default Configuration (can be overridden by config file)
LOG_FILE="/var/log/apache2/access.log"  # Default log file to monitor
ERROR_PATTERN="HTTP/[0-9.]* 5[0-9][0-9]"  # Pattern for 500-series errors
ALERT_EMAIL="admin@example.com"  # Email recipient
FROM_EMAIL="logmonitor@$(hostname)"  # Sender email
SMTP_SERVER="localhost"  # SMTP server
CHECK_INTERVAL=60  # Check every 60 seconds
ALERT_THRESHOLD=5  # Alert after 5 errors
TIME_WINDOW=300  # Time window in seconds (5 minutes)
MAX_LOG_SIZE=1000000  # 1MB - max log size to track
ALERT_COOLDOWN=1800  # 30 minutes cooldown between alerts
ENABLE_SYSLOG=true  # Log to syslog
DEBUG_MODE=false  # Enable debug output

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# FUNCTIONS
###############################################################################

# Print with timestamp
log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)
            echo -e "${GREEN}[INFO]${NC} [$timestamp] $message"
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} [$timestamp] $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} [$timestamp] $message"
            ;;
        DEBUG)
            if [ "$DEBUG_MODE" = true ]; then
                echo -e "${BLUE}[DEBUG]${NC} [$timestamp] $message"
            fi
            ;;
    esac
    
    # Log to syslog if enabled
    if [ "$ENABLE_SYSLOG" = true ]; then
        logger -t "logmonitor" "$level: $message"
    fi
}

# Load configuration file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log_message INFO "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        log_message WARN "Configuration file not found. Using defaults."
    fi
}

# Create default configuration file
create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
# Log Monitor Configuration File

# Log file to monitor (supports wildcards for multiple files)
LOG_FILE="/var/log/apache2/access.log"

# Alternative log files (uncomment to use)
# LOG_FILE="/var/log/nginx/access.log"
# LOG_FILE="/var/log/httpd/access_log"
# LOG_FILE="/var/log/application/*.log"

# Error pattern (regex)
ERROR_PATTERN="HTTP/[0-9.]* 5[0-9][0-9]"

# Email configuration
ALERT_EMAIL="admin@example.com"
FROM_EMAIL="logmonitor@$(hostname)"
SMTP_SERVER="localhost"

# Monitoring settings
CHECK_INTERVAL=60        # Check every N seconds
ALERT_THRESHOLD=5        # Alert after N errors
TIME_WINDOW=300          # Within N seconds
ALERT_COOLDOWN=1800      # Cooldown between alerts (seconds)

# Features
ENABLE_SYSLOG=true       # Log to syslog
DEBUG_MODE=false         # Enable debug output
EOF
    log_message INFO "Created default configuration at $CONFIG_FILE"
}

# Validate configuration
validate_config() {
    local errors=0
    
    if [ ! -f "$LOG_FILE" ] && [ ! -d "$(dirname "$LOG_FILE")" ]; then
        log_message ERROR "Log file or directory does not exist: $LOG_FILE"
        ((errors++))
    fi
    
    if ! echo "$ALERT_EMAIL" | grep -qE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'; then
        log_message ERROR "Invalid email address: $ALERT_EMAIL"
        ((errors++))
    fi
    
    if [ "$CHECK_INTERVAL" -lt 1 ]; then
        log_message ERROR "CHECK_INTERVAL must be at least 1 second"
        ((errors++))
    fi
    
    if [ "$errors" -gt 0 ]; then
        log_message ERROR "Configuration validation failed with $errors error(s)"
        return 1
    fi
    
    log_message INFO "Configuration validated successfully"
    return 0
}

# Check if another instance is running
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log_message ERROR "Another instance is already running (PID: $pid)"
            return 1
        else
            log_message WARN "Stale lock file found. Removing..."
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    return 0
}

# Remove lock file
remove_lock() {
    rm -f "$LOCK_FILE"
}

# Initialize state file
init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "0" > "$STATE_FILE"  # Last check timestamp
        echo "0" >> "$STATE_FILE"  # Last alert timestamp
        echo "0" >> "$STATE_FILE"  # Last log position
        log_message INFO "Initialized state file: $STATE_FILE"
    fi
}

# Read state
read_state() {
    if [ -f "$STATE_FILE" ]; then
        LAST_CHECK=$(sed -n '1p' "$STATE_FILE")
        LAST_ALERT=$(sed -n '2p' "$STATE_FILE")
        LAST_POSITION=$(sed -n '3p' "$STATE_FILE")
    else
        LAST_CHECK=0
        LAST_ALERT=0
        LAST_POSITION=0
    fi
}

# Update state
update_state() {
    local check_time=$1
    local alert_time=$2
    local position=$3
    
    cat > "$STATE_FILE" << EOF
$check_time
$alert_time
$position
EOF
}

# Parse log line and extract error details
parse_log_line() {
    local line="$1"
    local timestamp=$(echo "$line" | grep -oE '\[[^]]+\]' | head -1 | tr -d '[]')
    local ip=$(echo "$line" | awk '{print $1}')
    local method=$(echo "$line" | grep -oE '(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS)')
    local url=$(echo "$line" | grep -oE '"[A-Z]+ [^ ]+ HTTP' | awk '{print $2}')
    local status=$(echo "$line" | grep -oE 'HTTP/[0-9.]* [0-9]{3}' | awk '{print $2}')
    
    echo "IP: $ip | Time: $timestamp | Method: $method | URL: $url | Status: $status"
}

# Monitor log file
monitor_logs() {
    local current_time=$(date +%s)
    local error_count=0
    local error_details=""
    
    read_state
    
    # Get current file size
    local current_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)
    
    # If log was rotated or truncated, reset position
    if [ "$current_size" -lt "$LAST_POSITION" ]; then
        log_message WARN "Log file appears to have been rotated. Resetting position."
        LAST_POSITION=0
    fi
    
    # Read new log entries
    if [ -f "$LOG_FILE" ]; then
        local new_errors=$(tail -c +$((LAST_POSITION + 1)) "$LOG_FILE" | grep -E "$ERROR_PATTERN")
        
        if [ -n "$new_errors" ]; then
            # Count errors in time window
            while IFS= read -r line; do
                if [ -n "$line" ]; then
                    ((error_count++))
                    local parsed=$(parse_log_line "$line")
                    error_details="${error_details}\n${line}\n  ${parsed}\n"
                    
                    log_message WARN "Detected error: $parsed"
                fi
            done <<< "$new_errors"
            
            log_message INFO "Found $error_count error(s) in this check"
            
            # Check if we should send alert
            local time_since_last_alert=$((current_time - LAST_ALERT))
            
            if [ "$error_count" -ge "$ALERT_THRESHOLD" ] && [ "$time_since_last_alert" -ge "$ALERT_COOLDOWN" ]; then
                send_alert "$error_count" "$error_details"
                LAST_ALERT=$current_time
            elif [ "$error_count" -ge "$ALERT_THRESHOLD" ]; then
                log_message INFO "Alert threshold met but in cooldown period (${time_since_last_alert}s / ${ALERT_COOLDOWN}s)"
            fi
        else
            log_message DEBUG "No errors found in this check"
        fi
        
        # Update position
        LAST_POSITION=$current_size
    else
        log_message ERROR "Log file not found: $LOG_FILE"
    fi
    
    # Update state
    update_state "$current_time" "$LAST_ALERT" "$LAST_POSITION"
}

# Send email alert
send_alert() {
    local error_count=$1
    local error_details=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local hostname=$(hostname)
    
    log_message INFO "Sending alert email to $ALERT_EMAIL"
    
    # Create email body
    local email_body=$(cat << EOF
Subject: [ALERT] HTTP 500 Errors Detected on $hostname
From: $FROM_EMAIL
To: $ALERT_EMAIL
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { background-color: white; padding: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { background-color: #d32f2f; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-box { background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 15px 0; }
        .error-details { background-color: #f8f9fa; padding: 15px; border-radius: 5px; font-family: monospace; font-size: 12px; overflow-x: auto; white-space: pre-wrap; }
        .info { color: #666; margin: 10px 0; }
        .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🚨 HTTP 500 Error Alert</h2>
        </div>
        
        <div class="alert-box">
            <strong>Alert Details:</strong>
            <ul>
                <li><strong>Hostname:</strong> $hostname</li>
                <li><strong>Timestamp:</strong> $timestamp</li>
                <li><strong>Error Count:</strong> $error_count errors detected</li>
                <li><strong>Log File:</strong> $LOG_FILE</li>
                <li><strong>Threshold:</strong> $ALERT_THRESHOLD errors</li>
            </ul>
        </div>
        
        <h3>Error Details:</h3>
        <div class="error-details">$(echo -e "$error_details" | sed 's/</\&lt;/g; s/>/\&gt;/g')</div>
        
        <div class="footer">
            <p>This is an automated alert from the Log Monitor Script.</p>
            <p>To stop receiving these alerts, please update the configuration at: $CONFIG_FILE</p>
        </div>
    </div>
</body>
</html>
EOF
)
    
    # Try to send email using available methods
    if command -v sendmail &> /dev/null; then
        echo -e "$email_body" | sendmail -t
        log_message INFO "Alert sent via sendmail"
    elif command -v mail &> /dev/null; then
        echo -e "$error_details" | mail -s "[ALERT] HTTP 500 Errors on $hostname" "$ALERT_EMAIL"
        log_message INFO "Alert sent via mail command"
    elif command -v mailx &> /dev/null; then
        echo -e "$error_details" | mailx -s "[ALERT] HTTP 500 Errors on $hostname" "$ALERT_EMAIL"
        log_message INFO "Alert sent via mailx"
    else
        log_message ERROR "No mail command available. Cannot send alert."
        log_message ERROR "Install sendmail, mailx, or configure SMTP"
        # Save to file as fallback
        local alert_file="/tmp/logmonitor_alert_$(date +%Y%m%d_%H%M%S).txt"
        echo -e "$error_details" > "$alert_file"
        log_message WARN "Alert saved to: $alert_file"
    fi
}

# Display statistics
display_stats() {
    read_state
    
    echo ""
    echo "================================================"
    echo "        Log Monitor Statistics"
    echo "================================================"
    echo "Log File:          $LOG_FILE"
    echo "Last Check:        $(date -d @$LAST_CHECK '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r $LAST_CHECK '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
    echo "Last Alert:        $(date -d @$LAST_ALERT '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r $LAST_ALERT '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
    echo "Last Position:     $LAST_POSITION bytes"
    echo "Alert Threshold:   $ALERT_THRESHOLD errors"
    echo "Check Interval:    $CHECK_INTERVAL seconds"
    echo "Alert Cooldown:    $ALERT_COOLDOWN seconds"
    echo "================================================"
    echo ""
}

# Display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Real-time log monitor with email alerts for HTTP 500 errors

OPTIONS:
    -h, --help              Show this help message
    -c, --config FILE       Use custom configuration file
    -l, --log FILE          Monitor specific log file
    -e, --email EMAIL       Send alerts to this email
    -t, --threshold NUM     Alert after NUM errors (default: 5)
    -i, --interval SEC      Check every SEC seconds (default: 60)
    -d, --daemon            Run as daemon (background)
    -s, --stats             Display statistics and exit
    -v, --verbose           Enable debug mode
    --init-config           Create default configuration file
    --test-alert            Send test alert email
    --stop                  Stop running daemon

EXAMPLES:
    # Run with default configuration
    $0

    # Run with custom config file
    $0 --config /etc/logmonitor.conf

    # Monitor specific log file
    $0 --log /var/log/nginx/access.log --email admin@example.com

    # Run as daemon with verbose output
    $0 --daemon --verbose

    # Display current statistics
    $0 --stats

    # Create default configuration
    $0 --init-config

EOF
}

# Test alert function
test_alert() {
    log_message INFO "Sending test alert..."
    local test_details="This is a test alert from Log Monitor Script\n\nTimestamp: $(date)\nHostname: $(hostname)\n\nIf you receive this email, your email configuration is working correctly."
    send_alert 1 "$test_details"
    log_message INFO "Test alert sent"
}

# Stop daemon
stop_daemon() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log_message INFO "Stopping daemon (PID: $pid)"
            kill "$pid"
            remove_lock
            log_message INFO "Daemon stopped"
        else
            log_message WARN "No running daemon found"
            remove_lock
        fi
    else
        log_message WARN "No lock file found. Daemon may not be running"
    fi
}

# Main monitoring loop
main_loop() {
    log_message INFO "Starting log monitor..."
    log_message INFO "Monitoring: $LOG_FILE"
    log_message INFO "Alert email: $ALERT_EMAIL"
    log_message INFO "Check interval: ${CHECK_INTERVAL}s"
    log_message INFO "Alert threshold: $ALERT_THRESHOLD errors"
    
    # Trap signals for cleanup
    trap cleanup EXIT INT TERM
    
    while true; do
        monitor_logs
        sleep "$CHECK_INTERVAL"
    done
}

# Cleanup function
cleanup() {
    log_message INFO "Shutting down log monitor..."
    remove_lock
    exit 0
}

###############################################################################
# MAIN
###############################################################################

# Parse command line arguments
DAEMON_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -l|--log)
            LOG_FILE="$2"
            shift 2
            ;;
        -e|--email)
            ALERT_EMAIL="$2"
            shift 2
            ;;
        -t|--threshold)
            ALERT_THRESHOLD="$2"
            shift 2
            ;;
        -i|--interval)
            CHECK_INTERVAL="$2"
            shift 2
            ;;
        -d|--daemon)
            DAEMON_MODE=true
            shift
            ;;
        -s|--stats)
            load_config
            display_stats
            exit 0
            ;;
        -v|--verbose)
            DEBUG_MODE=true
            shift
            ;;
        --init-config)
            create_default_config
            exit 0
            ;;
        --test-alert)
            load_config
            test_alert
            exit 0
            ;;
        --stop)
            stop_daemon
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Load configuration
load_config

# Validate configuration
if ! validate_config; then
    exit 1
fi

# Check for lock file
if ! check_lock; then
    exit 1
fi

# Initialize state
init_state

# Run in daemon mode or foreground
if [ "$DAEMON_MODE" = true ]; then
    log_message INFO "Starting in daemon mode..."
    nohup "$0" --config "$CONFIG_FILE" > /dev/null 2>&1 &
    log_message INFO "Daemon started with PID: $!"
else
    main_loop
fi