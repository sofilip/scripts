#!/bin/bash

# Define ANSI color codes for consistent styling
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

# Separator for the information lines
SEPARATOR="  "

# Function to get OS Name
get_os_name() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    elif [ -f /etc/lsb-release ]; then
        lsb_release -ds
    elif [ -f /etc/redhat-release ]; then
        cat /etc/redhat-release
    else
        echo "Unknown OS"
    fi
}

# Function to get package count
get_package_count() {
    local count=0
    if command -v dpkg &> /dev/null; then
        count=$((count + $(dpkg -l | grep -c '^ii')))
        echo -n "Debian/Ubuntu: $count"
    fi
    if command -v rpm &> /dev/null; then
        if [ $count -gt 0 ]; then echo -n ", "; fi
        count_rpm=$(rpm -qa | wc -l)
        echo -n "RPM: $count_rpm"
    fi
    if command -v pacman &> /dev/null; then
        if [ $count -gt 0 ]; then echo -n ", "; fi
        count_pacman=$(pacman -Q | wc -l)
        echo -n "Arch: $count_pacman"
    fi
    if command -v flatpak &> /dev/null; then
        if [ $count -gt 0 ]; then echo -n ", "; fi
        count_flatpak=$(flatpak list | wc -l)
        echo -n "Flatpak: $count_flatpak"
    fi
    if command -v snap &> /dev/null; then
        if [ $count -gt 0 ]; then echo -n ", "; fi
        count_snap=$(snap list | wc -l)
        echo -n "Snap: $count_snap"
    fi
    if [ $count -eq 0 ]; then
        echo "N/A (No common package manager found)"
    fi
}

# Function to get Desktop Environment
get_desktop_environment() {
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        echo "$XDG_CURRENT_DESKTOP"
    elif [ -n "$GDMSESSION" ]; then
        echo "$GDMSESSION"
    elif [ -n "$DESKTOP_SESSION" ]; then
        echo "$DESKTOP_SESSION"
    else
        echo "Unknown"
    fi
}

# Function to get Window Manager
get_window_manager() {
    if command -v wmctrl &> /dev/null; then
        wmctrl -m | grep "Name:" | cut -d ' ' -f 2-
    else
        echo "Unknown (wmctrl not found)"
    fi
}

# Function to get Terminal Font
get_terminal_font() {
    echo "Hard to determine from shell"
}

# Function to get CPU usage
get_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if [ -z "$cpu_usage" ]; then
        cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}')
        printf "%.1f%%" "$cpu_usage"
    else
        echo "${cpu_usage}%"
    fi
}

# Function to get RAM usage
get_ram_usage() {
    local mem_info=$(free | grep "Mem:")
    local total=$(echo $mem_info | awk '{print $2}')
    local used=$(echo $mem_info | awk '{print $3}')
    local available=$(echo $mem_info | awk '{print $7}')
    local usage_percent=$(awk "BEGIN {printf \"%.1f\", ($used/$total)*100}")
    
    echo "Used: $(numfmt --to=iec $((used*1024))) / $(numfmt --to=iec $((total*1024))) (${usage_percent}%)"
}

# Function to get connected users
get_connected_users() {
    who | wc -l
}

# Function to get disk usage for mounted filesystems
get_disk_usage() {
    df -h | grep -E '^/dev/' | while read filesystem size used available percent mountpoint; do
        echo "${LIGHT_BLUE}│${SEPARATOR}${SEPARATOR}${BLUE}${mountpoint}${NC}: ${used}/${size} (${percent})"
    done
}

# Function to get top 5 CPU processes
get_top_cpu_processes() {
    ps aux --sort=-%cpu | head -6 | tail -5 | while read user pid cpu mem vsz rss tty stat start time command; do
        echo "${LIGHT_BLUE}│${SEPARATOR}${SEPARATOR}${BLUE}${cpu}%${NC} - ${command:0:50}"
    done
}

# Function to get top 5 RAM processes
get_top_ram_processes() {
    ps aux --sort=-%mem | head -6 | tail -5 | while read user pid cpu mem vsz rss tty stat start time command; do
        echo "${LIGHT_BLUE}│${SEPARATOR}${SEPARATOR}${BLUE}${mem}%${NC} - ${command:0:50}"
    done
}

# i. Title with current date and time
echo -e "${LIGHT_BLUE}╭───────────── ${NC}${BLUE}System Information - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${GREEN}User: ${BLUE}$(whoami)${NC} ${GREEN}| Hostname: ${BLUE}$(hostname)${NC}"

# ii, iii. System Information
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}System Information${NC}"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰍹 OS${NC}: $(get_os_name)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰒋 Kernel${NC}: $(uname -r)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰅐 Uptime${NC}: $(uptime -p | sed 's/up //')"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰏖 Packages${NC}: $(get_package_count)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}👥 Connected Users${NC}: $(get_connected_users)"

# iv. System Load Information
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}System Load${NC}"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰻠 CPU Usage${NC}: $(get_cpu_usage)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰍛 RAM Usage${NC}: $(get_ram_usage)"

# Disk Usage
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}Disk Usage${NC}"
get_disk_usage

# vi. Top CPU Processes
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}Top 5 CPU Processes${NC}"
get_top_cpu_processes

# vii. Top RAM Processes
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}Top 5 RAM Processes${NC}"
get_top_ram_processes

# Desktop Environment (optional section)
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}Desktop Environment${NC}"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰧨 DE${NC}: $(get_desktop_environment)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󱂬 WM${NC}: $(get_window_manager)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰞷 Shell${NC}: $(basename "$SHELL")"
if command -v xdpyinfo &> /dev/null; then
    echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰹑 Resolution${NC}: $(xdpyinfo | grep dimensions | awk '{print $2}' 2>/dev/null || echo "N/A")"
fi

# Hardware Information
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│ ${NC}${YELLOW}Hardware Information${NC}"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰻠 CPU${NC}: $(grep -m 1 'model name' /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^ *//')"
if command -v lspci &> /dev/null; then
    echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰢮 GPU${NC}: $(lspci | grep -i vga | cut -d ':' -f 3- | sed 's/^ *//' || echo "N/A")"
fi

# Colors (decorative)
echo -e "${LIGHT_BLUE}│${NC}"
echo -e "${LIGHT_BLUE}│${NC}${SEPARATOR} \033[40m  \033[0m \033[41m  \033[0m \033[42m  \033[0m \033[43m  \033[0m \033[44m  \033[0m \033[45m  \033[0m \033[46m  \033[0m \033[47m  \033[0m"

# Footer
echo -e "${LIGHT_BLUE}╰───────────────────────────────────────────────────────╯${NC}"