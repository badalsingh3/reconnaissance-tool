#!/bin/bash

run_shodan_query() {
    local domain=$1
    local outdir=$2

    log "Running Shodan query on $domain"

    local api_key="${SHODAN_API_KEY:-}"
    if [ -z "$api_key" ]; then
        log "WARN: SHODAN_API_KEY not set, skipping Shodan lookup"
        return
    fi

    if ! command -v jq &> /dev/null; then
        log "WARN: jq not installed, skipping Shodan lookup"
        return
    fi

    local ip
    ip=$(dig +short A "$domain" | head -n1)

    if [ -z "$ip" ]; then
        log "WARN: could not resolve $domain to an IP, skipping Shodan lookup"
        return
    fi

    log "Resolved $domain to $ip, querying Shodan"

    local response
    response=$(curl -s -m 10 "https://api.shodan.io/shodan/host/${ip}?key=${api_key}")

    if ! echo "$response" | jq empty 2>/dev/null; then
        log "WARN: Shodan query failed or returned invalid data, skipping"
        echo "$response" > "${outdir}/raw/shodan_error.txt"
        return
    fi

    # save full raw response
    echo "$response" | jq . > "${outdir}/raw/shodan_results.json"
    log "Shodan query successful, saved raw results"

    # extract meaningful insights into a separate summary file
    {
        echo "IP: $ip"
        echo "Organization: $(echo "$response" | jq -r '.org // "unknown"')"
        echo "Operating System: $(echo "$response" | jq -r '.os // "unknown"')"
        echo "ISP: $(echo "$response" | jq -r '.isp // "unknown"')"
        echo "Country: $(echo "$response" | jq -r '.country_name // "unknown"')"
        echo ""
        echo "Open Ports:"
        echo "$response" | jq -r '.ports[]?' | sort -n | sed 's/^/  - /'
        echo ""
        echo "Known Vulnerabilities (CVEs):"
        local vulns
        vulns=$(echo "$response" | jq -r '.vulns // [] | .[]?')
        if [ -z "$vulns" ]; then
            echo "  None found"
        else
            echo "$vulns" | sed 's/^/  - /'
        fi
        echo ""
        echo "Service Banners:"
        echo "$response" | jq -r '.data[]? | "  - Port \(.port)/\(.transport // "tcp"): \(.product // "unknown service") \(.version // "")"'
    } > "${outdir}/raw/shodan_insights.txt"

    log "Shodan insights extracted"
}
