#!/bin/bash

run_whois() {
    local domain=$1
    local outdir=$2

    log "Running whois lookup on $domain"

    if ! command -v whois &> /dev/null; then
        log "WARN: whois not installed, skipping"
        return
    fi

    whois "$domain" > "${outdir}/raw/whois.txt" 2>&1
}
