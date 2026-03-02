#!/bin/bash
#
# PokiXonkorDev - Arch Linux Optimized Version
# Uses Arch-specific optimizations and parallel processing enhancements
#

VERSION="2.0.0-arch"

# Check for Arch-specific tools
if ! command -v pacman &> /dev/null; then
    echo "Warning: This version is optimized for Arch Linux"
fi

# Use parallel if available (Arch usually has it)
if command -v parallel &> /dev/null; then
    PARALLEL_AVAILABLE=true
    echo "[+] GNU Parallel detected - using enhanced parallelization"
else
    PARALLEL_AVAILABLE=false
    echo "[!] Install 'parallel' for better performance: sudo pacman -S parallel"
fi

# Source the main script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pokixonkordev.sh"

# Override scan function for parallel
if [[ "$PARALLEL_AVAILABLE" == true ]]; then
    run_scan() {
        local wordlist="$1"
        local base_url="${2:-$TARGET}"
        local current_depth="${3:-0}"
        
        if [[ $current_depth -ge $DEPTH ]]; then
            return
        fi
        
        local total_paths=$(generate_paths "$wordlist" | wc -l)
        
        echo -e "${CYAN}[*] Scanning with GNU Parallel (Arch optimized)${NC}"
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