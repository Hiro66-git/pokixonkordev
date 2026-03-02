# PokiXonkorDev

![Version](https://img.shields.io/badge/version-2.0.0-purple)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)

**Advanced Web Content Discovery Tool for Purple Team Operations**

PokiXonkorDev is a high-performance directory and file bruteforcer written in pure Bash, designed for security professionals conducting penetration testing and purple team exercises.

## Features

### Core Capabilities
- **Multi-threaded Scanning** - Configurable parallel requests (default: 20 threads)
- **Wildcard Detection** - Automatically detects and filters false positives
- **Recursive Scanning** - Discovers nested directories up to configurable depth
- **Extension Bruteforcing** - Tests multiple file extensions per path
- **Progress Tracking** - Real-time progress bars (with `pv`)
- **Detailed Statistics** - Comprehensive scan results and timing data

### HTTP Features
- **Multiple HTTP Methods** - GET, POST, HEAD support
- **Custom Headers** - Add authentication, tokens, or custom headers
- **Cookie Support** - Include session cookies
- **Proxy Support** - Route through HTTP/HTTPS proxies (Burp, ZAP, etc.)
- **Rate Limiting** - Control request rate to avoid detection/blocking
- **Redirect Handling** - Follow or ignore redirects
- **Timeout Configuration** - Prevent hanging on slow servers

### Output & Reporting
- **Color-coded Results** - Status code based coloring
- **File Output** - Save results to file
- **Verbose Mode** - Detailed debugging information
- **JSON Export** - Machine-readable output (planned)
- **Status Code Filtering** - Show only specified response codes

### Platform Optimizations
- **Universal Version** - Works on any Unix-like system
- **Arch Linux** - GNU Parallel integration
- **Fedora/RHEL** - HTTP/3 support, SELinux aware
- **macOS** - Homebrew curl, macOS-specific optimizations

## Installation

### Requirements

curl

bc

**All Platforms:**
```bash

Arch

# Install dependencies
sudo pacman -S curl bc pv parallel

# Clone repository
git clone https://github.com/Hiro66-git/pokixonkordev.git
cd pokixonkordev

# Make executable
chmod +x pokixonkordev-arch.sh

# Run
./pokixonkordev-arch.sh -u http://target.com -w wordlists/pokixonkor-mega.txt

Mac

# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install curl bc pv parallel

# Clone and run
git clone https://github.com/Hiro66-git/pokixonkordev.git
cd pokixonkordev
chmod +x pokixonkordev-mac.sh
./pokixonkordev-mac.sh -u http://target.com -w wordlists/pokixonkor-mega.txt


Fedora/RHEL/CentOS

# Install dependencies
sudo dnf install curl bc pv parallel

# Clone and run
git clone https://github.com/Hiro66-git/pokixonkordev.git
cd pokixonkordev
chmod +x pokixonkordev-fedora.sh
./pokixonkordev-fedora.sh -u http://target.com -w wordlists/pokixonkor-mega.txt

Windows (git/bash/wsl)

# WSL (Ubuntu/Debian)
sudo apt update
sudo apt install curl bc pv parallel

# Git Bash (use universal version)
# Download dependencies from GnuWin32 or use WSL instead

git clone https://github.com/Hiro66-git/pokixonkordev.git
cd pokixonkordev
chmod +x pokixonkordev.sh
./pokixonkordev.sh -u http://target.com -w wordlists/pokixonkor-mega.txt
