#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "  Recon Tool - Dependency Setup"
echo "=========================================="
echo ""

install_debian() {
    sudo apt update
    sudo apt install -y whois dnsutils jq curl
}

install_fedora() {
    sudo dnf install -y whois bind-utils jq curl
}

install_arch() {
    sudo pacman -Sy --noconfirm whois bind jq curl
}

if command -v apt &> /dev/null; then
    echo "Detected Debian/Ubuntu-based system"
    install_debian
elif command -v dnf &> /dev/null; then
    echo "Detected Fedora/RHEL-based system"
    install_fedora
elif command -v pacman &> /dev/null; then
    echo "Detected Arch-based system"
    install_arch
else
    echo "Could not detect a supported package manager (apt/dnf/pacman)."
    echo "Please install manually: whois, dig (dnsutils/bind-utils/bind), jq, curl"
    exit 1
fi

echo ""

# subfinder — installed via Go on every distro, not through package managers
if command -v subfinder &> /dev/null; then
    echo "subfinder already installed, skipping"
else
    if command -v go &> /dev/null; then
        echo "Installing subfinder via go install..."
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        echo "subfinder installed to \$(go env GOPATH)/bin — make sure that's in your PATH"
    else
        echo "Go is not installed. subfinder requires Go."
        echo "Install Go first: https://go.dev/doc/install"
        echo "Then run: go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    fi
fi

echo ""
echo "Setup complete. Optionally set your Shodan API key:"
echo "  cp .env.example .env"
echo "  # then edit .env and add your key"
echo ""
echo "Run the tool with: ./recon.sh <domain>"
