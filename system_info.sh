#!/bin/bash

# Define ANSI color codes for consistent styling
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
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

# Function to get Window Manager (basic attempt)
get_window_manager() {
    if command -v wmctrl &> /dev/null; then
        wmctrl -m | grep "Name:" | cut -d ' ' -f 2-
    else
        echo "Unknown (wmctrl not found)"
    fi
}

# Function to get Terminal Font (very difficult, often approximate or N/A)
get_terminal_font() {
    # This is highly dependent on the terminal and its configuration.
    # It's very hard to reliably get the active font from a shell script.
    # Often, it's not directly exposed via simple commands.
    # We'll just state that it's difficult to determine from shell.
    echo "Hard to determine from shell"
}

# Title
echo -e "${LIGHT_BLUE}╭───────────── ${NC}${BLUE}$(whoami)${NC}"

# System Information
echo -e "${LIGHT_BLUE}│ ${NC}System Information"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰍹 OS${NC}: $(get_os_name)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰒋 Kernel${NC}: $(uname -r)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰅐 Uptime${NC}: $(uptime -p | sed 's/up //')"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰏖 Packages${NC}: $(get_package_count)"
echo -e "${LIGHT_BLUE}│${NC}"

# Desktop Environment
echo -e "${LIGHT_BLUE}│ ${NC}Desktop Environment"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰧨 DE${NC}: $(get_desktop_environment)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󱂬 WM${NC}: $(get_window_manager)"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰉼 Theme${NC}: Unknown (Difficult to detect)" # Theme is very hard to detect reliably
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰹑 Resolution${NC}: $(xdpyinfo | grep dimensions | awk '{print $2}' || echo "N/A")"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰞷 Shell${NC}: $(basename "$SHELL")"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰛖 Font${NC}: $(get_terminal_font)"
echo -e "${LIGHT_BLUE}│${NC}"

# Hardware Information
echo -e "${LIGHT_BLUE}│ ${NC}Hardware Information"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰻠 CPU${NC}: $(grep -m 1 'model name' /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^ *//')"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰢮 GPU${NC}: $(lspci | grep -i vga | cut -d ':' -f 3- | sed 's/^ *//' || echo "N/A (lspci not found or no GPU detected)")"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰍛 Memory${NC}: $(free -h | awk '/Mem:/ {print $2 "/" $1}')"
echo -e "${LIGHT_BLUE}│${SEPARATOR}${BLUE}󰋊 Disk (/)${NC}: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo "N/A")"
echo -e "${LIGHT_BLUE}│${NC}"

# Colors (simulated with basic colored blocks)
echo -e "${LIGHT_BLUE}│${NC}${SEPARATOR}${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}  ${BLUE}󰋊 ${NC}" # Simple color block
echo -e "${LIGHT_BLUE}│${NC}${SEPARATOR} \033[40m  \033[0m \033[41m  \033[0m \033[42m  \033[0m \033[43m  \033[0m \033[44m  \033[0m \033[45m  \033[0m \033[46m  \033[0m \033[47m  \033[0m" # Basic ANSI colors
echo -e "${LIGHT_BLUE}│${NC}"

# Footer
echo -e "${LIGHT_BLUE}╰───────────────────────────────╯${NC}"
