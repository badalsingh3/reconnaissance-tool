#!/bin/bash

build_report() {
    local domain=$1
    local outdir=$2
    log "Building report"
    local report_file="${outdir}/report.html"

    local registrar creation_date expiry_date
    registrar=$(grep -i "Registrar:" "${outdir}/raw/whois.txt" 2>/dev/null | head -n1 | cut -d: -f2- | sed 's/^ *//' || true)
    creation_date=$(grep -iE "Creation Date:|Created:" "${outdir}/raw/whois.txt" 2>/dev/null | head -n1 | cut -d: -f2- | sed 's/^ *//' || true)
    expiry_date=$(grep -iE "Registry Expiry Date:|Expiration Date:" "${outdir}/raw/whois.txt" 2>/dev/null | head -n1 | cut -d: -f2- | sed 's/^ *//' || true)

    if [ -z "$registrar" ]; then registrar="not found"; fi
    if [ -z "$creation_date" ]; then creation_date="not found"; fi
    if [ -z "$expiry_date" ]; then expiry_date="not found"; fi

    local subdomain_count=0
    local subdomains_txt="none found"
    if [ -f "${outdir}/raw/subdomains.txt" ] && [ -s "${outdir}/raw/subdomains.txt" ]; then
        subdomain_count=$(wc -l < "${outdir}/raw/subdomains.txt" || true)
        subdomains_txt=$(cat "${outdir}/raw/subdomains.txt" || true)
    fi

    local dns_txt="no dns data"
    if [ -f "${outdir}/raw/dns_records.txt" ]; then
        dns_txt=$(cat "${outdir}/raw/dns_records.txt" || true)
    fi

    local shodan_txt="no shodan data (missing api key or lookup failed)"
    if [ -f "${outdir}/raw/shodan_insights.txt" ]; then
        shodan_txt=$(cat "${outdir}/raw/shodan_insights.txt" || true)
    fi

    cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>recon: ${domain}</title>
<style>
    body {
        background: #111;
        color: #ddd;
        font-family: monospace;
        max-width: 800px;
        margin: 30px auto;
        padding: 0 15px;
    }
    a { color: #6cf; }
    h1 {
        font-size: 1.4em;
        border-bottom: 1px solid #333;
        padding-bottom: 8px;
    }
    h2 {
        font-size: 1.1em;
        color: #9c9;
        margin-top: 35px;
    }
    .meta {
        color: #777;
        font-size: 0.85em;
    }
    pre {
        background: #000;
        border-left: 2px solid #333;
        padding: 10px 15px;
        overflow-x: auto;
        white-space: pre-wrap;
        font-size: 0.9em;
    }
</style>
</head>
<body>
<h1>recon report: ${domain}</h1>
<p class="meta">generated $(date '+%Y-%m-%d %H:%M:%S')</p>
<h2>whois</h2>
<pre>registrar:      ${registrar}
created:        ${creation_date}
expires:        ${expiry_date}</pre>
<h2>dns records</h2>
<pre>${dns_txt}</pre>
<h2>subdomains (${subdomain_count})</h2>
<pre>${subdomains_txt}</pre>
<h2>shodan</h2>
<pre>${shodan_txt}</pre>
</body>
</html>
EOF
    log "Report generated at ${report_file}"
}
