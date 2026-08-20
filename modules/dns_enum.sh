#!/bin/bash

run_dns_enum() {
    local domain=$1
    local outdir=$2

    log "Running DNS enumeration on $domain"

    if ! command -v dig &> /dev/null; then
        log "WARN: dig not installed, skipping"
        return
    fi

    {
        echo "------------------------A Records------------------------------"
        dig +noall +answer "$domain" A
        echo "------------------------AAAA Records---------------------------"
        dig +noall +answer "$domain" AAAA
        echo "------------------------CNAME Records---------------------------"
        dig +noall +answer "$domain" CNAME
        echo "------------------------NS Records------------------------------"
        dig +noall +answer "$domain" NS
        echo "------------------------MX Records------------------------------"
        dig +noall +answer "$domain" MX
        echo "------------------------TXT Records------------------------------"
        dig +noall +answer "$domain" TXT
    } >> "${outdir}/raw/dns_records.txt" 2>&1
}
