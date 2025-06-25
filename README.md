# Ghosttify 👻

> Transform any bash script into a beautiful, interactive Ghostty terminal experience with enhanced path compatibility and visual feedback.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![macOS](https://img.shields.io/badge/macOS-compatible-brightgreen.svg)](https://www.apple.com/macos/)
[![Ghostty](https://img.shields.io/badge/Ghostty-required-purple.svg)](https://ghostty.org/)

## ✨ Features

- 🔧 **Smart Path Fixing** - Automatically handles `BASH_SOURCE`, `$0`, `dirname`, and relative path compatibility issues
- 🎨 **Beautiful Terminal UI** - Colorful output with progress indicators and status messages  
- 📱 **macOS Notifications** - Get notified when scripts complete with success/failure status
- 🛡️ **Safety First** - Detects and warns about potential compatibility issues before processing
- 📁 **Enhanced File Sourcing** - Custom source function with intelligent fallbacks for relative imports
- ⚡ **Zero Configuration** - Works out of the box with any bash script
- 🔍 **Pattern Analysis** - Scans scripts for complex path dependencies and provides helpful guidance
- 🎯 **Preserves Originals** - Never modifies your original scripts, creates `_ghostty.sh` versions

## 🚀 Quick Start

1. **Install Ghostty** (if you haven't already):
   ```bash
   # Download from https://ghostty.org/
   # Or install via Homebrew (when available)
   ```

2. **Download Ghosttify**:
   ```bash
   curl -O https://raw.githubusercontent.com/danialrami/ghosttify/main/ghosttify.sh
   chmod +x ghosttify.sh
   ```

3. **Run it**:
   ```bash
   ./ghosttify.sh
   ```

4. **Enter your script path** when prompted and watch the magic happen! ✨

## 🎯 Perfect For

- **System Monitoring Scripts** - Get visual feedback from system reports and monitoring tools
- **Build Automation** - Run build scripts with beautiful progress indicators
- **Audio/Media Workflows** - Perfect for sound designers and musicians using command-line tools
- **DevOps Utilities** - Enhanced UX for deployment and maintenance scripts
- **Development Tools** - Make boring utility scripts look professional
- **Any Bash Script** - If it runs in bash, Ghosttify can enhance it!

## 🛠️ How It Works

Ghosttify analyzes your bash script and creates an enhanced version that:

1. **Fixes Path Issues** - Automatically resolves common path detection problems when scripts run from temporary locations
2. **Enhances User Experience** - Adds colorful output, progress indicators, and notifications
3. **Preserves Functionality** - Your script works exactly the same, just with better presentation
4. **Handles Edge Cases** - Smart detection of relative sourcing, directory changes, and complex path patterns

### Smart Path Compatibility

Ghosttify automatically handles these common bash patterns:

```bash
# These problematic patterns are automatically fixed:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$0")/config.sh"
CONFIG_FILE="$(realpath "$(dirname "${BASH_SOURCE[0]}")/settings.conf")"
```

## 📋 Requirements

- **macOS** (for `osascript` notifications and `open` command)
- **Ghostty terminal** ([Download here](https://ghostty.org/))
- **Bash 4.0+** (standard on modern macOS)

## 🔧 Advanced Usage

### Pattern Detection

Ghosttify analyzes your scripts and warns about potential issues:

- **Relative File Sourcing** - Scripts that source other files relative to their location
- **Directory Changes** - Scripts that use `cd` commands which might affect relative paths
- **Complex Path Resolution** - Advanced patterns like `realpath`, `readlink`, or `BASH_SOURCE` arrays
- **BASH_SOURCE Dependencies** - Scripts that heavily rely on bash's source tracking

### Environment Variables

Ghostified scripts have access to these helpful variables:

```bash
$ORIGINAL_SCRIPT_PATH    # Full path to the original script
$ORIGINAL_SCRIPT_DIR     # Directory containing the original script  
$ORIGINAL_SCRIPT_NAME    # Filename of the original script
$GHOSTTIFY_ORIGINAL_SOURCE  # Fallback for BASH_SOURCE compatibility
```

### Enhanced Source Function

Ghosttified scripts include a smart `source` function that:

1. First tries to source files from the original script directory
2. Falls back to the current working directory
3. Provides helpful error messages with search paths
4. Maintains compatibility with both `source` and `.` commands

## 🎨 Examples

### Before (boring):
```bash
$ ./backup-script.sh
Creating backup...
Backup complete.
```

### After (beautiful):
```bash
🚀 Running: /Users/you/scripts/backup-script.sh
📁 Script directory: /Users/you/scripts
📂 Working directory: /Users/you/scripts

Creating backup...
Backup complete.

✅ Script completed successfully!
```
*Plus you get a macOS notification when it's done!*

## 🧠 How Ghosttify Handles Edge Cases

### Complex Scripts
- **Multi-file projects** with relative imports
- **Build scripts** that change directories
- **Package managers** with complex path logic
- **Audio processing pipelines** with asset dependencies

### Path Resolution Patterns
- `${BASH_SOURCE[0]}` and `${BASH_SOURCE[n]}`
- `$(dirname "$0")` and variants
- `$(realpath "$(dirname "$0")")` 
- `$(readlink -f "$0")`
- `${0%/*}` parameter expansion
- `$(pwd)/$(dirname "$0")` combinations

### Source/Import Handling
- Relative source commands: `source ./config.sh`
- BASH_SOURCE-based imports: `source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"`
- Dynamic imports with variables
- Nested sourcing chains

## 🤝 Contributing

We welcome contributions! Some ideas:

- Support for other terminal emulators
- Linux/Windows compatibility  
- Additional path pattern detection
- Integration with other notification systems
- Performance optimizations

## 📝 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Ghostty** - The amazing terminal that makes this all possible
- **The Bash Community** - For creating such a powerful scripting environment
- **Sound Designers & Musicians** - The creative community that inspired this tool

## 🐛 Troubleshooting

### Common Issues

**Script doesn't run in Ghostty:**
- Ensure Ghostty is installed and in your Applications folder
- Check that the original script has execute permissions

**Path-related errors:**
- Ghosttify tries to fix most path issues, but complex scripts may need manual adjustment
- Check the compatibility warnings and tips provided during ghostification

**Sourcing failures:**
- Ensure all sourced files are accessible from the original script directory
- Use absolute paths for files outside the script directory

**macOS notifications not working:**
- Grant terminal/script permissions in System Preferences > Security & Privacy > Privacy > Notifications

### Getting Help

- Check the compatibility warnings Ghosttify provides
- Look at the generated script to understand what was changed
- File an issue on GitHub with your script details (remove sensitive info)

## 🎵 Perfect for Audio Workflows

Originally designed for sound designers and musicians, Ghosttify excels at:

- **Audio processing scripts** - Run Sox, FFmpeg, or custom DSP pipelines with visual feedback
- **Sample management** - Organize and process audio libraries with beautiful progress indicators  
- **Studio automation** - System monitoring and maintenance scripts for audio workstations
- **Live performance tools** - Quick utility scripts that need to run reliably during shows
- **Music production workflows** - Batch processing, format conversion, and asset management