# CTF Tools (autosetup) - Interactive Installer

A comprehensive, interactive tool installer for CTF (Capture The Flag) competitions and cybersecurity professionals. This project provides a modular, menu-driven interface to install and configure essential security tools on Kali Linux and compatible distributions.

## 🚀 Quick Installation

Install the CTF Tools installer with a single command:

```bash
curl -fsSL https://trustlab.upct.es/CTFsetup | sudo bash
```

After installation, run the tool with:

```bash
autosetup
```

## ✨ Features

### 🎯 Main Menu Sections

#### 1. **Categories** 🗂️
- Browse tools organized by security domains
- Web Security Tools
- Binary Analysis & Reverse Engineering
- Network Security & Scanning
- Cryptography Tools
- Forensics Tools
- Development Tools
- *Coming Soon: Full category implementation*

#### 2. **Beginner Setup** 🎓
- **Install All Tools**: Complete CTF environment setup (recommended for beginners)
- **Essential Tools Only**: Install just the core tools needed to get started
- **Custom Selection**: Advanced users can pick specific tools
- Quick start guide and tool information

#### 3. **Install Tools** 🛠️
- Interactive checkbox-based tool selection
- Two-column layout for easy browsing
- Quick selection presets:
  - Essential CTF Tools
  - Binary Analysis Tools
  - Web Security Tools
  - Network Tools
- Real-time selection counter
- Detailed tool information and descriptions

#### 4. **Setup Tools** ⚙️
- Configure installed tools
- Setup development environments
- Customize tool settings
- *Coming Soon: Advanced configuration options*

#### 5. **Visit Us!**
**Project Website**: [https://trustlab.upct.es](https://trustlab.upct.es)


## (dev) Architecture

The project now uses a **modular architecture** for better maintainability and extensibility:

```
CTFTools/
├── setup.sh                 # Main entry point
├── install.sh               # System installer
├── apps.json                # Tool configurations
├── core_functions/          # Core functionality modules
│   ├── colors_utils.sh      # Colors and utility functions
│   ├── app_manager.sh       # App loading and selection management
│   └── installer.sh         # Installation logic
├── menu_system/             # Menu interface modules
│   ├── main_menu.sh         # Main menu system
│   └── install_menu.sh      # Tool selection interface
└── scripts/                 # Individual tool install scripts
```

## 📦 Available Tools at the moment

Current tools include:

- **Kali Linux Headless** - Base system tools and fixes
- **Nmap** - Network exploration and security scanning
- **Hashcat** - Advanced password recovery
- **GDB with GEF** - Enhanced debugging with exploit development features
- **Checksec** - Binary security feature analyzer
- **Burp Suite** - Web application security testing
- **Ghidra** - NSA's reverse engineering suite
- **ROPgadget** - Return-oriented programming gadget finder
- **Pwntools** - CTF framework and exploit development library
- **Neovim** - Modern Vim fork with extensive plugin ecosystem
- **Terminal Text Editor** - Lightweight terminal-based editor

## 🎮 Usage Examples

### Quick Start for Beginners
1. Run `autosetup`
2. Select `2) Beginner Setup`
3. Choose `1) Install All Tools`
4. Confirm installation

### Custom Tool Selection
1. Run `autosetup`
2. Select `3) Install Tools`
3. Use numbers to toggle specific tools
4. Press `i` to install selected tools

### Quick Presets
1. In the Install Tools menu
2. Press `r` for quick selection presets
3. Choose from Essential, Binary, Web, or Network tools

## 🔄 System Requirements

- **OS**: Kali Linux (recommended) or Debian-based distributions
- **Architecture**: x64/AMD64
- **Dependencies**: `jq`, `curl` (automatically installed)
- **Privileges**: Regular user with sudo access
- **Internet**: Required for downloading tools and updates

## 🤝 Contributing

We welcome contributions! Here's how you can help:

- 🌟 **Star the repository** on GitHub
- 🐛 **Report bugs** and issues
- 💡 **Suggest new features** or tools
- 📝 **Contribute code** or documentation
- 📢 **Share with the community**

## 🔗 Links

- **GitHub Repository**: [https://github.com/varo6/CTFTools](https://github.com/varo6/CTFTools)
- **Issues & Bug Reports**: Use GitHub Issues
- **Latest Version**: Always available via the installation command

## 📄 License

This project is open source and available under standard open source licensing terms.

## 🎯 Roadmap

### Coming Soon:
- **Full Category Implementation**: Complete tool categorization
- **Advanced Configuration**: Post-installation tool setup
- **Tool Dependencies**: Smart dependency management
- **Custom Tool Addition**: Add your own tools to the installer
- **Export/Import Selections**: Save and share tool configurations
- **Installation Profiles**: Predefined setups for different use cases

---

**Made with ❤️ for the CTF and cybersecurity community**

*Version 1.0.6 - Modular Edition*
