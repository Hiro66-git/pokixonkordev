#!/bin/bash
#
# PokiXonkorDev - macOS Optimized Version
# Uses macOS-specific utilities and optimizations
#

VERSION="2.0.0-macos"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "[!] Warning: This version is optimized for macOS"
fi

# macOS uses different temp directory
TEMP_DIR="$TMPDIR/pokixonkordev-$$"
mkdir -p "$TEMP_DIR"

# Check for Homebrew curl (often newer than system curl)
if [[ -f /opt/homebrew/bin/curl ]] || [[ -f /usr/local/bin/curl ]]; then
    BREW_CURL=$(which -a curl | grep -E "(homebrew|local)" | head -n1)
    if [[ -n "$BREW_CURL" ]]; then
        echo "[+] Using Homebrew curl: $BREW_CURL"
        alias curl="$BREW_CURL"
    fi
fi

# macOS doesn't have /dev/urandom in the same way - use better random source
generate_random_string() {
    local length="${1:-32}"
    LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c "$length"
}

# Check for macOS-specific parallel tools
if command -v gparallel &> /dev/null; then
    echo "[+] GNU Parallel (gparallel) detected"
    alias parallel="gparallel"
    PARALLEL_AVAILABLE=true
elif command -v parallel &> /dev/null; then
    PARALLEL_AVAILABLE=true
else
    PARALLEL_AVAILABLE=false
    echo "[!] Install GNU Parallel for better performance: brew install parallel"
fi

# macOS uses different 'bc' - ensure compatibility
if ! command -v bc &> /dev/null; then
    echo "[!] bc not found. Install it: brew install bc"
    exit 1
fi

# Check for pv
if ! command -v pv &> /dev/null; then
    echo "[!] pv not found. Install it for progress bars: brew install pv"
    PROGRESS_BAR=false
fi

# Source main script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pokixonkordev.sh"

# Override wildcard test for macOS random generation
test_wildcard() {
    echo -e "${CYAN}[*] Testing for wildcard responses...${NC}"
    
    local test_paths=(
        "$(generate_random_string 32)"
        "$(generate_random_string 32)"
        "$(generate_random_string 32)"
    )
    
    declare -A responses
    
    for path in "${test_paths[@]}"; do
        local result=$(check_url "${TARGET}/${path}")
        local status=$(echo "$result" | cut -d'|' -f1)
        local size=$(echo "$result" | cut -d'|' -f2)
        
        responses["$status"]=$((${responses[$status]:-0} + 1))
        
        if [[ "$VERBOSE" == true ]]; then
            echo -e "${YELLOW}  [Test] /${path} -> $status ($size bytes)${NC}"
        fi
    done
    
    for status in "${!responses[@]}"; do
        local count=${responses[$status]}
        local ratio=$(echo "scale=2; $count / ${#test_paths[@]}" | bc)
        
        if (( $(echo "$ratio >= $WILDCARD_THRESHOLD" | bc -l) )); then
            WILDCARD_DETECTED=true
            WILDCARD_STATUS="$status"
            echo -e "${YELLOW}[!] Wildcard response detected! Server returns $status for non-existent paths${NC}"
            echo -e "${YELLOW}[!] Results may contain false positives${NC}"
            echo -e "${YELLOW}[!] Filtering out status code: $status${NC}"
            return
        fi
    done
    
    echo -e "${GREEN}[+] No wildcard responses detected${NC}"
}

export -f test_wildcard generate_random_string

# Override for parallel if available
if [[ "$PARALLEL_AVAILABLE" == true ]]; then
    run_scan() {
        local wordlist="$1"
        local base_url="${2:-$TARGET}"
        local current_depth="${3:-0}"
        
        if [[ $current_depth -ge $DEPTH ]]; then
            return
        fi
        
        local total_paths=$(generate_paths "$wordlist" | wc -l | tr -d ' ')
        
        echo -e "${CYAN}[*] Scanning with GNU Parallel (macOS optimized)${NC}"
        echo -e "${CYAN}[*] Scanning depth $((current_depth + 1))/$DEPTH${NC}"
        echo -e "${CYAN}[*] Base URL: $base_url${NC}"
        echo -e "${CYAN}[*] Total paths to test: $total_paths${NC}"
        echo ""
        
        generate_paths "$wordlist" | \
            parallel --bar --jobs "$THREADS" \
            "scan_path {} \"$base_url\""
        
        if [[ "$RECURSIVE" == true ]] && [[ ${#FOUND_DIRS[@]} -gt 0 ]]; then
            local dirs_to_scan=("${FOUND_DIRS[@]}")
            FOUND_DIRS=()
            
            for dir in "${dirs_to_scan[@]}"; do
                echo ""
                echo -e "${MAGENTA}[*] Recursing into: /$dir${NC}"
                run_scan "$wordlist" "${base_url}/${dir}" $((current_depth + 1))
            done
        fi
    }
fi