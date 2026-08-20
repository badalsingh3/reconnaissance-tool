#!/bin/bash

run_subdomain_enum() {
    local domain=$1
    local outdir=$2

    log "Running subdomain enumeration on $domain"

    if ! command -v subfinder &> /dev/null; then
        log "WARN: subfinder not installed, skipping"
        return
    fi

    subfinder -d "$domain" -o "${outdir}/raw/subdomains.txt" -silent > /dev/null 2>&1
}
