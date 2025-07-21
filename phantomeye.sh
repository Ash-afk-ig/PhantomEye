#!/bin/bash

# phantomeye.sh - Comprehensive Network and Web Scanner

# --- Global Variables ---
TARGET=""
MODE=""
PORTS=""
OUTPUT_FILE=""
VERBOSE=0

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Logging Functions ---
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# --- Help Function ---
show_help() {
    echo -e "Usage: ${GREEN}pe --target <IP/HOSTNAME/RANGE> --mode <MODE> [OPTIONS]${NC}"
    echo ""
    echo "Phantomeye: The Comprehensive Bash-based Network and Web Scanner"
    echo ""
    echo "Options:"
    echo "  -t, --target <IP/HOSTNAME/RANGE>  : Specify the target(s) for scanning."
    echo "                                    Examples: 192.168.1.1, example.com, 192.168.1.0/24"
    echo "                                    (REQUIRED for all modes)"
    echo "  -m, --mode <MODE>                 : Specify the scanning mode. (REQUIRED)"
    echo "                                    Available Modes:"
    echo "                                      discovery : Fast host discovery (ping scan)."
    echo "                                      portscan  : Basic port scan on common ports."
    echo "                                      services  : Port scan with service/version detection."
    echo "                                      vulners   : General system/network vulnerability scan (Nmap NSE)."
    echo "                                      webvuln   : Web application vulnerability scan (cURL/Nmap HTTP NSE)."
    echo "                                      full      : Comprehensive scan (combines discovery, services, vulners, webvuln)."
    echo "  -p, --ports <PORT_RANGE>          : Specify custom port(s) or port range for scanning."
    echo "                                    Examples: 80,443,8080 or 1-1024 (applies to portscan, services, vulners modes)"
    echo "                                    (Optional: defaults to common ports if not specified)"
    echo "  -o, --output <FILE>               : Save scan results to the specified file."
    echo "                                    (Optional: results printed to stdout if not specified)"
    echo "  -v, --verbose                     : Enable verbose output for more details during scans."
    echo "                                    (Optional)"
    echo "  -h, --help                        : Display this help message and exit."
    echo ""
    echo "Examples:"
    echo "  pe -m discovery -t 192.168.1.0/24"
    echo "  pe --mode services --target scanme.nmap.org"
    echo "  pe -m vulners -t 10.0.0.5 -o system_vulns_report.txt"
    echo "  pe --mode webvuln --target example.com --verbose"
    echo "  pe -m full -t 192.168.1.0/24 -o full_network_report.log"
}

# --- Argument Parsing ---
parse_args() {
    # Using getopt for robust argument parsing
    # Options:
    # h: help
    # t: target (required argument)
    # m: mode (required argument)
    # p: ports (optional argument)
    # o: output (optional argument)
    # v: verbose (flag)
    TEMP=$(getopt -o ht:m:p:o:v --long help,target:,mode:,ports:,output:,verbose -- "$@")

    if [ $? -ne 0 ]; then
        log_error "Failed to parse options. Use 'pe -h' for help."
        exit 1
    fi

    eval set -- "$TEMP"

    while true; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -t|--target)
                TARGET="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -p|--ports)
                PORTS="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                log_error "Internal error: unknown option '$1'"
                show_help
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [ -z "$TARGET" ]; then
        log_error "Target is required. Use 'pe -h' for help."
        exit 1
    fi
    if [ -z "$MODE" ]; then
        log_error "Scanning mode is required. Use 'pe -h' for help."
        exit 1
    fi

    # Validate mode
    case "$MODE" in
        "discovery"|"portscan"|"services"|"vulners"|"webvuln"|"full")
            ;; # Valid mode
        *)
            log_error "Invalid scanning mode: '$MODE'. Use 'pe -h' for available modes."
            exit 1
            ;;
    esac
}

# --- Core Scan Functions (Placeholders - Implement Nmap/cURL/jq logic here) ---

run_discovery_scan() {
    log_info "Running discovery scan on target: $TARGET"
    # Example: nmap -sn "$TARGET"
    # Capture output to a variable or pipe to file_output_handler
    # For a range, you'd parse live hosts and pass to other scans in 'full' mode
    # For now, just a placeholder command
    log_verbose "Executing: nmap -sn \"$TARGET\""
    nmap_output=$(nmap -sn "$TARGET" 2>&1)
    file_output_handler "discovery" "$nmap_output"
    log_success "Discovery scan complete."
}

run_portscan() {
    log_info "Running port scan on target: $TARGET"
    local nmap_ports_arg=""
    if [ -n "$PORTS" ]; then
        nmap_ports_arg="-p $PORTS"
    fi
    # Example: nmap -sS $nmap_ports_arg "$TARGET"
    log_verbose "Executing: nmap -sS $nmap_ports_arg \"$TARGET\""
    nmap_output=$(nmap -sS $nmap_ports_arg "$TARGET" 2>&1)
    file_output_handler "portscan" "$nmap_output"
    log_success "Port scan complete."
}

run_services_scan() {
    log_info "Running services scan on target: $TARGET"
    local nmap_ports_arg=""
    if [ -n "$PORTS" ]; then
        nmap_ports_arg="-p $PORTS"
    fi
    # Example: nmap -sV $nmap_ports_arg "$TARGET"
    log_verbose "Executing: nmap -sV $nmap_ports_arg \"$TARGET\""
    nmap_output=$(nmap -sV $nmap_ports_arg "$TARGET" 2>&1)
    file_output_handler "services" "$nmap_output"
    log_success "Services scan complete."
}

run_vulners_scan() {
    log_info "Running vulnerability scan on target: $TARGET"
    local nmap_ports_arg=""
    if [ -n "$PORTS" ]; then
        nmap_ports_arg="-p $PORTS"
    fi
    # Example: nmap -sV -Pn --script=vuln,auth,brute,default $nmap_ports_arg "$TARGET"
    # Note: -Pn is used to skip host discovery, assuming target is known to be live
    log_verbose "Executing: nmap -sV -Pn --script=vuln,auth,brute,default $nmap_ports_arg \"$TARGET\""
    nmap_output=$(nmap -sV -Pn --script=vuln,auth,brute,default $nmap_ports_arg "$TARGET" 2>&1)
    file_output_handler "vulners" "$nmap_output"
    log_success "Vulnerability scan complete."
}

run_webvuln_scan() {
    log_info "Running web vulnerability scan on target: $TARGET"
    # Example: Use cURL for basic checks, then Nmap HTTP scripts
    # For Nmap: nmap -sV -Pn --script="http-enum,http-vuln*,http-headers,http-robots.txt,http-sitemap-generator" "$TARGET" -p 80,443,...
    # This mode might need more complex logic to determine HTTP/HTTPS ports if not explicitly given.
    local nmap_web_ports=""
    if [ -n "$PORTS" ]; then
        nmap_web_ports="-p $PORTS" # User-specified ports
    else
        nmap_web_ports="-p 80,443,8080,8443" # Common web ports
    fi

    log_verbose "Executing Nmap HTTP scripts: nmap -sV -Pn --script=\"http-enum,http-vuln*,http-headers,http-robots.txt,http-sitemap-generator\" $nmap_web_ports \"$TARGET\""
    nmap_output=$(nmap -sV -Pn --script="http-enum,http-vuln*,http-headers,http-robots.txt,http-sitemap-generator" $nmap_web_ports "$TARGET" 2>&1)
    file_output_handler "webvuln_nmap" "$nmap_output"

    # You could add cURL checks here, e.g., for specific paths or headers
    # curl_output=$(curl -s -I "http://$TARGET" 2>&1)
    # file_output_handler "webvuln_curl" "$curl_output"

    log_success "Web vulnerability scan complete."
}

run_full_scan() {
    log_info "Running comprehensive full scan on target: $TARGET"
    local hosts_to_scan="$TARGET"
    local timestamp=$(date +"%Y%m%d_%H%M%S")

    # If target is a range, first run discovery to get live hosts
    if [[ "$TARGET" == *"/"* ]]; then # Simple check for CIDR
        log_info "Target is a network range. Performing initial discovery scan..."
        discovery_output=$(nmap -sn "$TARGET" | grep "Nmap scan report for" | awk '{print $NF}' | sed 's/[()]//g' | tr '\n' ' ')
        if [ -n "$discovery_output" ]; then
            hosts_to_scan="$discovery_output"
            log_success "Discovered live hosts: $hosts_to_scan"
        else
            log_warn "No live hosts found in range: $TARGET. Skipping further scans."
            return
        fi
    fi

    # Iterate over hosts (or just the single target)
    for host in $hosts_to_scan; do
        log_info "Starting full scan for individual host: $host"
        local individual_output_file_base=""
        if [ -n "$OUTPUT_FILE" ]; then
            # Create a unique output file for each host within the main output file's directory
            individual_output_file_base="${OUTPUT_FILE%.*}_${host}_${timestamp}"
        fi

        # Run services scan
        log_info "  Running services scan on $host..."
        nmap_services_output=$(nmap -sV -Pn "$host" 2>&1)
        file_output_handler "full_services" "$nmap_services_output" "$individual_output_file_base_services"

        # Run vulners scan
        log_info "  Running vulnerability scan on $host..."
        nmap_vulners_output=$(nmap -sV -Pn --script=vuln,auth,brute,default "$host" 2>&1)
        file_output_handler "full_vulners" "$nmap_vulners_output" "$individual_output_file_base_vulners"

        # Run webvuln scan
        log_info "  Running web vulnerability scan on $host..."
        nmap_web_output=$(nmap -sV -Pn --script="http-enum,http-vuln*,http-headers,http-robots.txt,http-sitemap-generator" -p 80,443,8080,8443 "$host" 2>&1)
        file_output_handler "full_webvuln" "$nmap_web_output" "$individual_output_file_base_webvuln"
        log_success "Full scan complete for host: $host."
    done

    log_success "Comprehensive full scan complete for all targets."
}

# --- Output Handling ---
file_output_handler() {
    local scan_type="$1"
    local content="$2"
    local custom_base_file="$3" # Optional: for full scan's individual host outputs

    if [ -n "$OUTPUT_FILE" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local output_dir=$(dirname "$OUTPUT_FILE")
        local output_base_name=$(basename "$OUTPUT_FILE" .log) # Remove .log if present

        # Create output directory if it doesn't exist
        mkdir -p "$output_dir"

        local final_output_file=""
        if [ -n "$custom_base_file" ]; then
            final_output_file="${custom_base_file}_${scan_type}.log"
        else
            final_output_file="${output_dir}/${output_base_name}_${TARGET//\//-}_${scan_type}_${timestamp}.log"
        fi

        echo "$content" >> "$final_output_file"
        log_info "Scan results for $scan_type saved to: ${GREEN}$final_output_file${NC}"
    else
        echo "$content"
    fi
}

# --- Main Logic ---
main() {
    parse_args "$@"

    case "$MODE" in
        "discovery")
            run_discovery_scan
            ;;
        "portscan")
            run_portscan
            ;;
        "services")
            run_services_scan
            ;;
        "vulners")
            run_vulners_scan
            ;;
        "webvuln")
            run_webvuln_scan
            ;;
        "full")
            run_full_scan
            ;;
        *)
            log_error "This should not happen. Invalid mode detected after parsing."
            show_help
            exit 1
            ;;
    esac
}

# --- Execute Main ---
main "$@"