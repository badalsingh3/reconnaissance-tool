#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: ./recon.sh <domain>"
    exit 1
fi

domain="$1"

if ! [[ "$domain" =~ ^([a-zA-Z0-9](-?[a-zA-Z0-9])*\.)+[a-zA-Z]{2,}$ ]]; then
    echo "Error: '$domain' doesn't look like a valid domain"
    exit 1
fi

# load api keys if .env exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

timestamp=$(date +%Y%m%d_%H%M%S)
outdir="output/${domain}_${timestamp}"
mkdir -p "${outdir}/raw"

source lib/logger.sh
source lib/report_builder.sh
source modules/whois_lookup.sh
source modules/dns_enum.sh
source modules/subdomain_enum.sh
source modules/shodan_query.sh

echo "=========================================="
echo "  Recon Automation Tool"
echo "  Target: $domain"
echo "=========================================="
echo "Note: this can take a few minutes..."
echo ""

log "Starting recon on $domain"
log "Output directory: $outdir"

run_whois "$domain" "$outdir"
run_dns_enum "$domain" "$outdir"
run_subdomain_enum "$domain" "$outdir"
run_shodan_query "$domain" "$outdir"

build_report "$domain" "$outdir"

log "Recon complete."
echo ""
echo "Report ready: file://$(realpath "${outdir}/report.html")"

if command -v xdg-open &> /dev/null; then
    xdg-open "${outdir}/report.html" &> /dev/null &
elif command -v open &> /dev/null; then
    open "${outdir}/report.html"
fi
