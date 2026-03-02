#!/bin/bash
#
# PokiXonkorDev - Advanced Web Content Discovery Tool
# Universal Version
# Author: Hiro66-git
# License: MIT
#

VERSION="2.0.0"
BANNER_COLOR='\033[1;35m'  # Magenta

# ASCII Art Banner
print_banner() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║  ██████╗  ██████╗ ██╗  ██╗██╗██╗  ██╗ ██████╗ ███╗   ██╗██╗  ██╗   ║
║  ██╔══██╗██╔═══██╗██║ ██╔╝██║╚██╗██╔╝██╔═══██╗████╗  ██║██║ ██╔╝    ║
║  ██████╔╝██║   ██║█████╔╝ ██║ ╚███╔╝ ██║   ██║██╔██╗ ██║█████╔╝     ║
║  ██╔═══╝ ██║   ██║██╔═██╗ ██║ ██╔██╗ ██║   ██║██║╚██╗██║██╔═██╗     ║
║  ██║     ╚██████╔╝██║  ██╗██║██╔╝ ██╗╚██████╔╝██║ ╚████║██║  ██╗    ║
║  ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝   ║
║                                                                       ║
║                 ██████╗ ███████╗██╗   ██╗                            ║
║                 ██╔══██╗██╔════╝██║   ██║                            ║
║                 ██║  ██║█████╗  ██║   ██║                            ║
║                 ██║  ██║██╔══╝  ╚██╗ ██╔╝                            ║
║                 ██████╔╝███████╗ ╚████╔╝                             ║
║                 ╚═════╝ ╚══════╝  ╚═══╝                              ║
║                                                                      ║
║           Advanced Web Content Discovery Tool v1.1.0                ║
║                     Multi-Platform Support                         ║
║                                                                     ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
TARGET=""
WORDLIST=""
THREADS=20
EXTENSIONS=""
STATUS_CODES="200,201,204,301,302,307,308,401,403,405"
OUTPUT_FILE=""
RECURSIVE=false
DEPTH=1
CURRENT_DEPTH=0
USER_AGENT="PokiXonkorDev/$VERSION (Purple Team Scanner)"
TIMEOUT=10
FOLLOW_REDIRECTS=true
WILDCARD_DETECTION=true
WILDCARD_THRESHOLD=0.95
PROGRESS_BAR=true
RATE_LIMIT=0
PROXY=""
HEADERS=()
COOKIE=""
METHOD="GET"
VERBOSE=false

# Statistics
declare -A STATS
STATS[total_requests]=0
STATS[found_200]=0
STATS[found_301]=0
STATS[found_302]=0
STATS[found_401]=0
STATS[found_403]=0
STATS[found_405]=0
STATS[found_500]=0
STATS[total_found]=0
START_TIME=$(date +%s)

# Global arrays
declare -a FOUND_DIRS
declare -a SCANNED_PATHS
WILDCARD_DETECTED=false
WILDCARD_STATUS=""

# Temp files
TEMP_DIR=$(mktemp -d)
PROGRESS_FILE="$TEMP_DIR/progress"
RESULTS_FILE="$TEMP_DIR/results"
trap "rm -rf $TEMP_DIR" EXIT

# Lock file for statistics
STATS_LOCK="$TEMP_DIR/stats.lock"

# Usage
usage() {
    echo -e "${CYAN}${BOLD}USAGE:${NC}"
    echo "  $0 -u <url> -w <wordlist> [options]"
    echo ""
    echo -e "${CYAN}${BOLD}REQUIRED:${NC}"
    echo "  -u, --url <url>          Target URL (http://example.com)"
    echo "  -w, --wordlist <file>    Path to wordlist file"
    echo ""
    echo -e "${CYAN}${BOLD}SCANNING OPTIONS:${NC}"
    echo "  -t, --threads <num>      Parallel threads (default: 20)"
    echo "  -x, --extensions <list>  Extensions to append (php,html,txt,jsp)"
    echo "  -s, --status <codes>     Status codes to show (default: 200,301,302,401,403,405)"
    echo "  -m, --method <method>    HTTP method (GET, POST, HEAD) (default: GET)"
    echo "  -r, --recursive          Enable recursive directory scanning"
    echo "  -d, --depth <num>        Maximum recursion depth (default: 1)"
    echo "  --no-wildcard            Disable wildcard detection"
    echo "  --no-progress            Disable progress bar"
    echo ""
    echo -e "${CYAN}${BOLD}HTTP OPTIONS:${NC}"
    echo "  -a, --user-agent <str>   Custom User-Agent string"
    echo "  -H, --header <header>    Add custom header (can use multiple times)"
    echo "  -c, --cookie <cookie>    Cookie string"
    echo "  -p, --proxy <proxy>      Proxy URL (http://127.0.0.1:8080)"
    echo "  --timeout <sec>          Request timeout (default: 10)"
    echo "  --no-follow              Don't follow redirects"
    echo ""
    echo -e "${CYAN}${BOLD}OUTPUT OPTIONS:${NC}"
    echo "  -o, --output <file>      Save results to file"
    echo "  -v, --verbose            Verbose output"
    echo "  --json                   Output in JSON format"
    echo ""
    echo -e "${CYAN}${BOLD}RATE LIMITING:${NC}"
    echo "  --rate-limit <ms>        Delay between requests in milliseconds"
    echo ""
    echo -e "${CYAN}${BOLD}EXAMPLES:${NC}"
    echo "  Basic scan:"
    echo "    $0 -u http://target.com -w wordlist.txt"
    echo ""
    echo "  Scan with extensions and 50 threads:"
    echo "    $0 -u http://target.com -w wordlist.txt -x php,html,txt -t 50"
    echo ""
    echo "  Recursive scan with depth 2:"
    echo "    $0 -u http://target.com -w wordlist.txt -r -d 2"
    echo ""
    echo "  Scan through proxy with custom headers:"
    echo "    $0 -u http://target.com -w wordlist.txt -p http://127.0.0.1:8080 -H \"Authorization: Bearer token\""
    echo ""
    echo "  Only show 200 responses, save to file:"
    echo "    $0 -u http://target.com -w wordlist.txt -s 200 -o results.txt"
    echo ""
    exit 1
}

# Check dependencies
check_dependencies() {
    local missing=0
    local deps=("curl" "bc")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${RED}[!] Missing dependency: $dep${NC}"
            missing=1
        fi
    done
    
    # Optional dependencies
    if command -v pv &> /dev/null; then
        PROGRESS_BAR=true
    else
        if [[ "$PROGRESS_BAR" == true ]]; then
            echo -e "${YELLOW}[!] 'pv' not found. Progress bar disabled.${NC}"
            PROGRESS_BAR=false
        fi
    fi
    
    if [[ $missing -eq 1 ]]; then
        echo -e "${RED}[!] Please install missing dependencies${NC}"
        exit 1
    fi
}

# Parse arguments
parse_args() {
    if [[ $# -eq 0 ]]; then
        print_banner
        echo ""
        usage
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--url)
                TARGET="$2"
                shift 2
                ;;
            -w|--wordlist)
                WORDLIST="$2"
                shift 2
                ;;
            -t|--threads)
                THREADS="$2"
                shift 2
                ;;
            -x|--extensions)
                EXTENSIONS="$2"
                shift 2
                ;;
            -s|--status)
                STATUS_CODES="$2"
                shift 2
                ;;
            -m|--method)
                METHOD="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -r|--recursive)
                RECURSIVE=true
                shift
                ;;
            -d|--depth)
                DEPTH="$2"
                shift 2
                ;;
            -a|--user-agent)
                USER_AGENT="$2"
                shift 2
                ;;
            -H|--header)
                HEADERS+=("$2")
                shift 2
                ;;
            -c|--cookie)
                COOKIE="$2"
                shift 2
                ;;
            -p|--proxy)
                PROXY="$2"
                shift 2
                ;;
            --timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            --rate-limit)
                RATE_LIMIT="$2"
                shift 2
                ;;
            --no-wildcard)
                WILDCARD_DETECTION=false
                shift
                ;;
            --no-progress)
                PROGRESS_BAR=false
                shift
                ;;
            --no-follow)
                FOLLOW_REDIRECTS=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                print_banner
                echo ""
                usage
                ;;
            *)
                echo -e "${RED}[!] Unknown option: $1${NC}"
                usage
                ;;
        esac
    done
    
    # Validation
    if [[ -z "$TARGET" ]]; then
        echo -e "${RED}[!] Target URL required (-u)${NC}"
        exit 1
    fi
    
    if [[ -z "$WORDLIST" ]]; then
        echo -e "${RED}[!] Wordlist required (-w)${NC}"
        exit 1
    fi
    
    if [[ ! -f "$WORDLIST" ]]; then
        echo -e "${RED}[!] Wordlist file not found: $WORDLIST${NC}"
        exit 1
    fi
    
    # Normalize target URL
    TARGET="${TARGET%/}"
    
    # Validate method
    if [[ ! "$METHOD" =~ ^(GET|POST|HEAD)$ ]]; then
        echo -e "${RED}[!] Invalid HTTP method: $METHOD${NC}"
        exit 1
    fi
}

# Atomic increment for statistics (thread-safe)
increment_stat() {
    local key="$1"
    local value="${2:-1}"
    
    (
        flock -x 200
        STATS[$key]=$((${STATS[$key]} + value))
    ) 200>"$STATS_LOCK"
}

# Make HTTP request
check_url() {
    local url="$1"
    local curl_opts=(-s -o /dev/null -w "%{http_code}|%{size_download}|%{time_total}")
    
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
    
    # Rate limiting
    if [[ $RATE_LIMIT -gt 0 ]]; then
        sleep $(echo "scale=3; $RATE_LIMIT/1000" | bc)
    fi
    
    local response
    response=$(curl "${curl_opts[@]}" "$url" 2>/dev/null)
    
    echo "$response"
}

# Check if status code should be displayed
should_display() {
    local code="$1"
    
    if [[ "$STATUS_CODES" == *"$code"* ]]; then
        return 0
    fi
    return 1
}

# Get color for status code
get_status_color() {
    local code="$1"
    
    case $code in
        200|201|204)
            echo "$GREEN"
            ;;
        301|302|307|308)
            echo "$BLUE"
            ;;
        401)
            echo "$CYAN"
            ;;
        403)
            echo "$YELLOW"
            ;;
        405)
            echo "$MAGENTA"
            ;;
        500|502|503)
            echo "$RED"
            ;;
        *)
            echo "$NC"
            ;;
    esac
}

# Wildcard detection
test_wildcard() {
    echo -e "${CYAN}[*] Testing for wildcard responses...${NC}"
    
    local test_paths=(
        "$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)"
        "$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)"
        "$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)"
    )
    
    declare -A responses
    local similar_count=0
    
    for path in "${test_paths[@]}"; do
        local result=$(check_url "${TARGET}/${path}")
        local status=$(echo "$result" | cut -d'|' -f1)
        local size=$(echo "$result" | cut -d'|' -f2)
        
        responses["$status"]=$((${responses[$status]:-0} + 1))
        
        if [[ "$VERBOSE" == true ]]; then
            echo -e "${YELLOW}  [Test] /${path} -> $status ($size bytes)${NC}"
        fi
    done
    
    # Check if majority of responses are the same
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

# Check if path was already scanned
is_scanned() {
    local path="$1"
    
    for scanned in "${SCANNED_PATHS[@]}"; do
        if [[ "$scanned" == "$path" ]]; then
            return 0
        fi
    done
    return 1
}

# Scan single path
scan_path() {
    local path="$1"
    local base_url="$2"
    
    if [[ -z "$base_url" ]]; then
        base_url="$TARGET"
    fi
    
    local url="${base_url}/${path}"
    
    # Skip if already scanned
    if is_scanned "$url"; then
        return
    fi
    
    SCANNED_PATHS+=("$url")
    
    local result=$(check_url "$url")
    local status=$(echo "$result" | cut -d'|' -f1)
    local size=$(echo "$result" | cut -d'|' -f2)
    local time=$(echo "$result" | cut -d'|' -f3)
    
    increment_stat "total_requests"
    
    # Skip wildcard status
    if [[ "$WILDCARD_DETECTED" == true ]] && [[ "$status" == "$WILDCARD_STATUS" ]]; then
        return
    fi
    
    if should_display "$status"; then
        local color=$(get_status_color "$status")
        local size_kb=$(echo "scale=2; $size / 1024" | bc)
        
        local output_line="[$status] [${size_kb}KB] [${time}s] $url"
        
        echo -e "${color}$output_line${NC}"
        echo "$output_line" >> "$RESULTS_FILE"
        
        if [[ -n "$OUTPUT_FILE" ]]; then
            echo "$output_line" >> "$OUTPUT_FILE"
        fi
        
        increment_stat "total_found"
        increment_stat "found_$status"
        
        # Store directories for recursion
        if [[ "$RECURSIVE" == true ]] && [[ "$status" =~ ^(301|302|200)$ ]]; then
            if [[ "$path" != */ ]]; then
                FOUND_DIRS+=("$path")
            fi
        fi
    fi
}

# Export functions for parallel execution
export -f scan_path check_url should_display get_status_color increment_stat is_scanned
export TARGET USER_AGENT TIMEOUT STATUS_CODES OUTPUT_FILE METHOD FOLLOW_REDIRECTS
export PROXY COOKIE RATE_LIMIT VERBOSE WILDCARD_DETECTED WILDCARD_STATUS
export RED GREEN YELLOW BLUE CYAN MAGENTA NC
export TEMP_DIR STATS_LOCK RESULTS_FILE
export -A STATS
export HEADERS

# Generate paths from wordlist
generate_paths() {
    local wordlist="$1"
    
    if [[ -z "$EXTENSIONS" ]]; then
        cat "$wordlist"
    else
        IFS=',' read -ra EXT_ARRAY <<< "$EXTENSIONS"
        
        while IFS= read -r word; do
            # Original word
            echo "$word"
            
            # With extensions
            for ext in "${EXT_ARRAY[@]}"; do
                echo "${word}.${ext}"
            done
        done < "$wordlist"
    fi
}

# Main scanning function
run_scan() {
    local wordlist="$1"
    local base_url="${2:-$TARGET}"
    local current_depth="${3:-0}"
    
    if [[ $current_depth -ge $DEPTH ]]; then
        return
    fi
    
    local total_paths=$(generate_paths "$wordlist" | wc -l)
    
    echo -e "${CYAN}[*] Scanning depth $((current_depth + 1))/$DEPTH${NC}"
    echo -e "${CYAN}[*] Base URL: $base_url${NC}"
    echo -e "${CYAN}[*] Total paths to test: $total_paths${NC}"
    echo ""
    
    if [[ "$PROGRESS_BAR" == true ]] && command -v pv &> /dev/null; then
        generate_paths "$wordlist" | pv -l -s "$total_paths" -N "Progress" | \
            xargs -P "$THREADS" -I {} bash -c "scan_path \"{}\" \"$base_url\""
    else
        generate_paths "$wordlist" | \
            xargs -P "$THREADS" -I {} bash -c "scan_path \"{}\" \"$base_url\""
    fi
    
    # Recursive scanning
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

# Print statistics
print_stats() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))
    local req_per_sec=0
    
    if [[ $elapsed -gt 0 ]]; then
        req_per_sec=$(echo "scale=2; ${STATS[total_requests]} / $elapsed" | bc)
    fi
    
    echo ""
    echo -e "${MAGENTA}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}${BOLD}║                    SCAN COMPLETE                           ║${NC}"
    echo -e "${MAGENTA}${BOLD}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${MAGENTA}${BOLD}║${NC} ${GREEN}Total URLs Found:${NC}        ${BOLD}${STATS[total_found]}${NC}"
    echo -e "${MAGENTA}${BOLD}║${NC} ${BLUE}Total Requests:${NC}          ${STATS[total_requests]}"
    echo -e "${MAGENTA}${BOLD}║${NC} ${CYAN}Requests/Second:${NC}         $req_per_sec"
    echo -e "${MAGENTA}${BOLD}║${NC} ${YELLOW}Time Elapsed:${NC}            ${elapsed}s"
    echo -e "${MAGENTA}${BOLD}║${NC}"
    echo -e "${MAGENTA}${BOLD}║${NC} ${BOLD}Status Code Breakdown:${NC}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${GREEN}200 OK:${NC}                 ${STATS[found_200]}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${BLUE}301 Moved:${NC}              ${STATS[found_301]}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${BLUE}302 Found:${NC}              ${STATS[found_302]}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${CYAN}401 Unauthorized:${NC}       ${STATS[found_401]}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${YELLOW}403 Forbidden:${NC}          ${STATS[found_403]}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${MAGENTA}405 Not Allowed:${NC}        ${STATS[found_405]}"
    echo -e "${MAGENTA}${BOLD}║${NC}   ${RED}500 Server Error:${NC}       ${STATS[found_500]}"
    
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo -e "${MAGENTA}${BOLD}║${NC}"
        echo -e "${MAGENTA}${BOLD}║${NC} ${GREEN}Results saved to:${NC}       $OUTPUT_FILE"
    fi
    
    echo -e "${MAGENTA}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
}

# Main execution
main() {
    print_banner
    echo ""
    
    check_dependencies
    parse_args "$@"
    
    echo -e "${CYAN}[*] Target: $TARGET${NC}"
    echo -e "${CYAN}[*] Wordlist: $WORDLIST ($(wc -l < "$WORDLIST") words)${NC}"
    echo -e "${CYAN}[*] Threads: $THREADS${NC}"
    echo -e "${CYAN}[*] Method: $METHOD${NC}"
    echo -e "${CYAN}[*] Timeout: ${TIMEOUT}s${NC}"
    
    if [[ -n "$EXTENSIONS" ]]; then
        echo -e "${CYAN}[*] Extensions: $EXTENSIONS${NC}"
    fi
    
    if [[ "$RECURSIVE" == true ]]; then
        echo -e "${CYAN}[*] Recursive: enabled (depth: $DEPTH)${NC}"
    fi
    
    echo ""
    
    # Clear output file
    if [[ -n "$OUTPUT_FILE" ]]; then
        > "$OUTPUT_FILE"
        echo -e "${GREEN}[+] Output will be saved to: $OUTPUT_FILE${NC}"
        echo ""
    fi
    
    # Wildcard detection
    if [[ "$WILDCARD_DETECTION" == true ]]; then
        test_wildcard
        echo ""
    fi
    
    # Run scan
    run_scan "$WORDLIST"
    
    # Print statistics
    print_stats
}

# Execute
main "$@"