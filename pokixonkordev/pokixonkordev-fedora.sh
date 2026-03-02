#!/bin/bash
#
# PokiXonkorDev - Fedora/RHEL Optimized Version
# Uses SELinux-aware operations and Fedora-specific paths
#

VERSION="2.0.0-fedora"

# Check for Fedora/RHEL
if [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
    echo "[+] Fedora/RHEL system detected"
    
    # Check SELinux status
    if command -v getenforce &> /dev/null; then
        SELINUX_STATUS=$(getenforce)
        if [[ "$SELINUX_STATUS" == "Enforcing" ]]; then
            echo "[!] SELinux is in Enforcing mode - some operations may be restricted"
        fi
    fi
else
    echo "[!] Warning: This version is optimized for Fedora/RHEL systems"
fi

# Fedora often uses different temp directory permissions
TEMP_DIR="/var/tmp/pokixonkordev-$$"
mkdir -p "$TEMP_DIR"
chmod 700 "$TEMP_DIR"

# Check for Fedora-specific curl with HTTP/3 support
if curl --version | grep -q "HTTP3"; then
    echo "[+] HTTP/3 support detected in curl"
    HTTP3_AVAILABLE=true
else
    HTTP3_AVAILABLE=false
fi

# Source main script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pokixonkordev.sh"

# Override check_url if HTTP/3 is available
if [[ "$HTTP3_AVAILABLE" == true ]]; then
    check_url() {
        local url="$1"
        local curl_opts=(-s -o /dev/null -w "%{http_code}|%{size_download}|%{time_total}")
        
        curl_opts+=(--http3)  # Use HTTP/3 when available
        curl_opts+=(-X "$METHOD")
        curl_opts+=(-A "$USER_AGENT")
        curl_opts+=(--max-time "$TIMEOUT")
        curl_opts+=(--connect-timeout 5)
        
        if [[ "$FOLLOW_REDIRECTS" == true ]]; then
            curl_opts+=(-L)
        fi
        
        if [[ -n "$PROXY" ]]; then
            curl_opts+=(-x "$PROXY")
        fi
        
        if [[ -n "$COOKIE" ]]; then
            curl_opts+=(-b "$COOKIE")
        fi
        
        for header in "${HEADERS[@]}"; do
            curl_opts+=(-H "$header")
        done
        
        if [[ $RATE_LIMIT -gt 0 ]]; then
            sleep $(echo "scale=3; $RATE_LIMIT/1000" | bc)
        fi
        
        local response
        response=$(curl "${curl_opts[@]}" "$url" 2>/dev/null)
        
        echo "$response"
    }
    
    export -f check_url
fi