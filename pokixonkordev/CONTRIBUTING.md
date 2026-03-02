# Contributing to PokiXonkorDev

First off, thank you for considering contributing to PokiXonkorDev! It's people like you that make this tool better for the entire security community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Adding Wordlist Entries](#adding-wordlist-entries)
  - [Code Contributions](#code-contributions)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Community](#community)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. We pledge to:

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Using the tool for unauthorized/illegal scanning
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of unacceptable behavior may be reported by opening an issue or contacting the project maintainers. All complaints will be reviewed and investigated.

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

When creating a bug report, include:

**Required Information:**
- **Bug Description:** Clear and concise description
- **To Reproduce:** Steps to reproduce the behavior
- **Expected Behavior:** What you expected to happen
- **Actual Behavior:** What actually happened
- **Environment:**
  - OS: [e.g., Arch Linux, macOS 13, Windows WSL2]
  - Script Version: [e.g., pokixonkordev-arch.sh v2.0.0]
  - Bash Version: [output of `bash --version`]
  - curl Version: [output of `curl --version`]

**Optional but Helpful:**
- Screenshots
- Error logs
- Minimal reproducible example
- Relevant configuration

**Example Bug Report:**

```markdown
## Bug: Wildcard detection fails on Cloudflare sites

**Description:**
Wildcard detection incorrectly flags Cloudflare-protected sites as having wildcards.

**To Reproduce:**
1. Run: `./pokixonkordev.sh -u https://example-with-cloudflare.com -w wordlists/pokixonkor-mega.txt`
2. Observe wildcard detection warning
3. Manual testing shows 404s are returned correctly

**Expected:** No wildcard warning
**Actual:** False positive wildcard detection

**Environment:**
- OS: Ubuntu 22.04 LTS
- Script: pokixonkordev.sh v2.0.0
- Bash: 5.1.16
- curl: 7.81.0

**Logs:**