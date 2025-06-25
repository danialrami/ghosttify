#!/bin/bash

# Ghostify Script - Convert any bash script to run in a new Ghostty window
# Enhanced version with better path handling and edge case support

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_SCRIPT="/tmp/ghosttify-$TIMESTAMP.sh"

# Function to show notification
show_notification() {
    osascript -e "display notification \"$1\" with title \"Ghosttify\"" 2>/dev/null || true
}

# Set up PATH to include common locations
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$HOME/Library/Python/3.*/bin:$PATH"

# Create a temporary script to run in the new window
cat > "$TEMP_SCRIPT" << 'SCRIPT_EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to show notification
show_notification() {
    osascript -e "display notification \"$1\" with title \"Ghosttify\"" 2>/dev/null || true
}

# Set up PATH to include common locations
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$HOME/Library/Python/3.*/bin:$PATH"

echo -e "${PURPLE}👻 Ghosttify - Script Ghostification Tool${NC}"
echo -e "${BLUE}🚀 Convert any bash script to run in a Ghostty window${NC}"
echo -e "${YELLOW}Timestamp: $(date)${NC}"
echo ""

# Prompt for script filepath
echo -e "${CYAN}📂 Enter the path to the script you want to ghosttify:${NC}"
read -p "Script path: " ORIGINAL_SCRIPT

# Remove single quotes if user included them
ORIGINAL_SCRIPT=$(echo "$ORIGINAL_SCRIPT" | sed "s/^'//;s/'$//")

echo ""
echo -e "${BLUE}Processing: $ORIGINAL_SCRIPT${NC}"

# Validate input file
if [ ! -f "$ORIGINAL_SCRIPT" ]; then
    echo -e "${RED}❌ Error: File not found: $ORIGINAL_SCRIPT${NC}"
    show_notification "❌ File not found: $(basename "$ORIGINAL_SCRIPT")"
    echo ""
    echo -e "${YELLOW}Press any key to close this window...${NC}"
    read -n 1 -s
    exit 1
fi

if [ ! -r "$ORIGINAL_SCRIPT" ]; then
    echo -e "${RED}❌ Error: Cannot read file: $ORIGINAL_SCRIPT${NC}"
    show_notification "❌ Cannot read file: $(basename "$ORIGINAL_SCRIPT")"
    echo ""
    echo -e "${YELLOW}Press any key to close this window...${NC}"
    read -n 1 -s
    exit 1
fi

# Normalize the path to absolute
ORIGINAL_SCRIPT=$(cd "$(dirname "$ORIGINAL_SCRIPT")" 2>/dev/null && pwd)/$(basename "$ORIGINAL_SCRIPT")

# Check if script is already ghosttified
if grep -q "# Ghostified version of" "$ORIGINAL_SCRIPT" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Warning: This script appears to already be ghosttified!${NC}"
    echo -e "${CYAN}Original file: $ORIGINAL_SCRIPT${NC}"
    echo ""
    echo -e "${PURPLE}🔄 If you continue, this will create a ghosttified version of an already ghosttified script.${NC}"
    echo -e "${YELLOW}This might result in nested Ghostty windows (inception mode! 🤯)${NC}"
    echo ""
    read -p "Continue anyway? (y/N): " CONTINUE_ANYWAY
    
    if [[ ! "$CONTINUE_ANYWAY" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}ℹ️  Operation cancelled. No changes made.${NC}"
        show_notification "ℹ️ Ghosttify cancelled - script already ghosttified"
        echo ""
        echo -e "${YELLOW}Press any key to close this window...${NC}"
        read -n 1 -s
        exit 0
    fi
    echo -e "${YELLOW}🚀 Proceeding with ghosttifying already ghosttified script...${NC}"
    echo ""
fi

# Generate output filename
SCRIPT_DIR=$(dirname "$ORIGINAL_SCRIPT")
SCRIPT_NAME=$(basename "$ORIGINAL_SCRIPT" .sh)
OUTPUT_SCRIPT="${SCRIPT_DIR}/${SCRIPT_NAME}_ghostty.sh"

echo -e "${CYAN}📝 Output will be: $OUTPUT_SCRIPT${NC}"
echo ""

# Get script content (skip shebang if present)
if head -n 1 "$ORIGINAL_SCRIPT" | grep -q "^#!/"; then
    SCRIPT_CONTENT=$(tail -n +2 "$ORIGINAL_SCRIPT")
else
    SCRIPT_CONTENT=$(cat "$ORIGINAL_SCRIPT")
fi

# Check for common patterns that might need path fixing
echo -e "${CYAN}🔍 Analyzing script for path-dependent patterns...${NC}"

# Detect if script uses relative imports/sourcing
HAS_RELATIVE_SOURCES=false
if echo "$SCRIPT_CONTENT" | grep -qE '(source|\.)\s+[^/]*\.(sh|bash)' || \
   echo "$SCRIPT_CONTENT" | grep -qE '(source|\.)\s+"\$\{?BASH_SOURCE.*\}?/|"\$\(dirname.*\)/'; then
    HAS_RELATIVE_SOURCES=true
    echo -e "${YELLOW}⚠️  Detected relative file sourcing${NC}"
fi

# Detect if script changes directory
HAS_CD_COMMANDS=false
if echo "$SCRIPT_CONTENT" | grep -qE '^\s*cd\s+' && ! echo "$SCRIPT_CONTENT" | grep -qE '^\s*#.*cd\s+'; then
    HAS_CD_COMMANDS=true
    echo -e "${YELLOW}⚠️  Detected directory change commands${NC}"
fi

# Detect complex path patterns
HAS_COMPLEX_PATHS=false
if echo "$SCRIPT_CONTENT" | grep -qE '(realpath|readlink|pwd.*dirname|BASH_SOURCE\[[^0]\])'; then
    HAS_COMPLEX_PATHS=true
    echo -e "${YELLOW}⚠️  Detected complex path resolution patterns${NC}"
fi

# Detect BASH_SOURCE usage
HAS_BASH_SOURCE=false
if echo "$SCRIPT_CONTENT" | grep -qE 'BASH_SOURCE'; then
    HAS_BASH_SOURCE=true
    echo -e "${YELLOW}⚠️  Detected BASH_SOURCE usage (may have limitations)${NC}"
fi

# Smart path fixing - enhanced version
echo -e "${CYAN}🔧 Applying enhanced smart path fixes...${NC}"

# Escape the original script path for safe sed usage
ORIGINAL_SCRIPT_SAFE=$(echo "$ORIGINAL_SCRIPT" | sed 's/[[\.*^$()+?{|\/]/\\&/g')
SCRIPT_DIR_SAFE=$(echo "$SCRIPT_DIR" | sed 's/[[\.*^$()+?{|\/]/\\&/g')

# Create a temporary file for complex replacements
TEMP_FIXES="/tmp/path_fixes_$TIMESTAMP.sed"
cat > "$TEMP_FIXES" << FIXES_EOF
# Basic BASH_SOURCE patterns
s/\\\${BASH_SOURCE\[0\]}/$ORIGINAL_SCRIPT_SAFE/g
s/\\\$BASH_SOURCE\[0\]/$ORIGINAL_SCRIPT_SAFE/g
s/\\\${BASH_SOURCE\[0\]%/\*}/$SCRIPT_DIR_SAFE/g
s/\\\$BASH_SOURCE/$ORIGINAL_SCRIPT_SAFE/g

# Basic $0 patterns
s|\\\$(dirname "\\\$0")|\\\$(dirname "$ORIGINAL_SCRIPT_SAFE")|g
s|\\\$(dirname \\\$0)|\\\$(dirname "$ORIGINAL_SCRIPT_SAFE")|g
s|\\\${0%/\*}|$SCRIPT_DIR_SAFE|g

# Realpath patterns
s|realpath.*dirname.*\\\$0.*)|"$SCRIPT_DIR_SAFE"|g
s|realpath.*BASH_SOURCE.*)|"$ORIGINAL_SCRIPT_SAFE"|g
s|\\\$(realpath "\\\$0")|"$ORIGINAL_SCRIPT_SAFE"|g

# Readlink patterns (common on Linux)
s|readlink -f.*dirname.*\\\$0.*)|"$SCRIPT_DIR_SAFE"|g
s|readlink -f.*BASH_SOURCE.*)|"$ORIGINAL_SCRIPT_SAFE"|g
s|\\\$(readlink -f "\\\$0")|"$ORIGINAL_SCRIPT_SAFE"|g

# PWD-based patterns (more careful with escaping)
s|\\\$(pwd)/\\\$(dirname "\\\$0")|"$SCRIPT_DIR_SAFE"|g
s|"\\\$(pwd)"/"\\\$(dirname "\\\$0")"|"$SCRIPT_DIR_SAFE"|g

# Complex SCRIPT_DIR patterns
s|SCRIPT_DIR="\\\$(cd "\\\$(dirname "\\\${BASH_SOURCE\[0\]}").*pwd)"|SCRIPT_DIR="$SCRIPT_DIR_SAFE"|g
s|SCRIPT_DIR=\\\$(cd \\\$(dirname \\\$0).*pwd)|SCRIPT_DIR="$SCRIPT_DIR_SAFE"|g
FIXES_EOF

# Apply fixes using sed script
SCRIPT_CONTENT=$(echo "$SCRIPT_CONTENT" | sed -f "$TEMP_FIXES")
rm -f "$TEMP_FIXES"

# Additional pattern-based replacements for edge cases
# Handle parameter expansion patterns
SCRIPT_CONTENT=$(echo "$SCRIPT_CONTENT" | sed "s|\\\${0##\*/}|$(basename "$ORIGINAL_SCRIPT")|g")

# Handle BASH_SOURCE array access beyond [0]
for i in {1..9}; do
    SCRIPT_CONTENT=$(echo "$SCRIPT_CONTENT" | sed "s/\\\${BASH_SOURCE\[$i\]}/$ORIGINAL_SCRIPT_SAFE/g")
done

echo -e "${GREEN}✅ Applied enhanced path compatibility fixes${NC}"

# Warn about potential issues
if [ "$HAS_RELATIVE_SOURCES" = true ] || [ "$HAS_CD_COMMANDS" = true ] || [ "$HAS_COMPLEX_PATHS" = true ] || [ "$HAS_BASH_SOURCE" = true ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Potential compatibility issues detected:${NC}"
    
    if [ "$HAS_RELATIVE_SOURCES" = true ]; then
        echo -e "${YELLOW}   - Script sources other files relative to its location${NC}"
        echo -e "${CYAN}     Consider using absolute paths or checking if sourced files exist${NC}"
    fi
    
    if [ "$HAS_CD_COMMANDS" = true ]; then
        echo -e "${YELLOW}   - Script changes working directory${NC}"
        echo -e "${CYAN}     This may affect relative path operations${NC}"
    fi
    
    if [ "$HAS_COMPLEX_PATHS" = true ]; then
        echo -e "${YELLOW}   - Script uses advanced path resolution${NC}"
        echo -e "${CYAN}     Some patterns might not be fully compatible${NC}"
    fi
    
    if [ "$HAS_BASH_SOURCE" = true ]; then
        echo -e "${YELLOW}   - Script uses BASH_SOURCE array${NC}"
        echo -e "${CYAN}     BASH_SOURCE behavior is simulated but may differ from original${NC}"
    fi
    
    echo ""
    read -p "Continue with ghostification? (Y/n): " CONTINUE_WITH_WARNINGS
    if [[ "$CONTINUE_WITH_WARNINGS" =~ ^[Nn]$ ]]; then
        echo -e "${BLUE}ℹ️  Operation cancelled. No changes made.${NC}"
        show_notification "ℹ️ Ghosttify cancelled by user"
        echo ""
        echo -e "${YELLOW}Press any key to close this window...${NC}"
        read -n 1 -s
        exit 0
    fi
fi

# Escape problematic characters for sed
ORIGINAL_SCRIPT_ESCAPED=$(echo "$ORIGINAL_SCRIPT" | sed 's/[[\.*^$()+?{|]/\\&/g')
SCRIPT_TITLE_ESCAPED=$(basename "$SCRIPT_NAME" | sed 's/[[\.*^$()+?{|]/\\&/g')

echo -e "${YELLOW}🔧 Generating ghosttified script...${NC}"

# Create the ghostified script with enhanced compatibility
cat > "$OUTPUT_SCRIPT" << 'GHOSTTIFY_EOF_MARKER'
#!/bin/bash

# Ghostified version of __ORIGINAL_SCRIPT_PLACEHOLDER__
# Auto-generated by ghosttify.sh (enhanced version)

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_SCRIPT="/tmp/ghosttified-script-$TIMESTAMP.sh"

# Create a temporary script to run in the new window
cat > "$TEMP_SCRIPT" << 'INNER_SCRIPT_EOF_MARKER'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to show notification
show_notification() {
    osascript -e "display notification \"$1\" with title \"__SCRIPT_TITLE_PLACEHOLDER__\"" 2>/dev/null || true
}

# Set up PATH to include common locations
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$HOME/Library/Python/3.*/bin:$PATH"

# Enhanced compatibility setup for ghosttified scripts
export ORIGINAL_SCRIPT_PATH="__ORIGINAL_SCRIPT_PLACEHOLDER__"
export ORIGINAL_SCRIPT_DIR="$(dirname "__ORIGINAL_SCRIPT_PLACEHOLDER__")"
export ORIGINAL_SCRIPT_NAME="$(basename "__ORIGINAL_SCRIPT_PLACEHOLDER__")"

# Change to original script directory for relative path compatibility
INITIAL_PWD="$(pwd)"
cd "$ORIGINAL_SCRIPT_DIR" 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Warning: Could not change to script directory${NC}"
}

echo -e "${BLUE}🚀 Running: __ORIGINAL_SCRIPT_PLACEHOLDER__${NC}"
echo -e "${YELLOW}Timestamp: $(date)${NC}"
echo -e "${CYAN}📁 Script directory: $ORIGINAL_SCRIPT_DIR${NC}"
echo -e "${CYAN}📂 Working directory: $(pwd)${NC}"
echo ""

# Override common path detection variables for maximum compatibility
SCRIPT_DIR="$ORIGINAL_SCRIPT_DIR"

# Set up BASH_SOURCE compatibility
# Since BASH_SOURCE is read-only, we provide a fallback mechanism
if [[ -z "${BASH_SOURCE[0]}" ]] || [[ "${BASH_SOURCE[0]}" == *"/tmp/"* ]]; then
    export GHOSTTIFY_ORIGINAL_SOURCE="__ORIGINAL_SCRIPT_PLACEHOLDER__"
    # For scripts that check BASH_SOURCE existence
    export GHOSTTIFY_HAS_BASH_SOURCE=1
fi

# Enhanced source function to handle relative sourcing with multiple fallbacks
source() {
    local file="$1"
    shift
    
    # If path is relative and doesn't start with /
    if [[ ! "$file" =~ ^/ ]]; then
        # Try script directory first
        if [[ -f "$ORIGINAL_SCRIPT_DIR/$file" ]]; then
            builtin source "$ORIGINAL_SCRIPT_DIR/$file" "$@"
        # Try current directory as fallback
        elif [[ -f "./$file" ]]; then
            builtin source "./$file" "$@"
        # Try without modification as last resort
        else
            builtin source "$file" "$@" || {
                echo -e "${YELLOW}⚠️  Warning: Could not source file: $file${NC}"
                echo -e "${CYAN}    Searched in: $ORIGINAL_SCRIPT_DIR and current directory${NC}"
                return 1
            }
        fi
    else
        # Absolute path - use as is
        builtin source "$file" "$@"
    fi
}

# Create . function instead of alias for better compatibility
function . {
    source "$@"
}

# Export the functions so they're available to sourced scripts
export -f source
export -f .

# Original script content starts here
__SCRIPT_CONTENT_PLACEHOLDER__

SCRIPT_EXIT_CODE=$?

# Return to initial directory if changed
cd "$INITIAL_PWD" 2>/dev/null

echo ""
if [[ $SCRIPT_EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✅ Script completed successfully!${NC}"
    show_notification "✅ __SCRIPT_TITLE_PLACEHOLDER__ completed successfully"
else
    echo -e "${RED}❌ Script failed with exit code: $SCRIPT_EXIT_CODE${NC}"
    show_notification "❌ __SCRIPT_TITLE_PLACEHOLDER__ failed (exit code: $SCRIPT_EXIT_CODE)"
fi

echo ""
echo -e "${YELLOW}Press any key to close this window...${NC}"
read -n 1 -s

# Clean up temp script
rm -f "$0"
INNER_SCRIPT_EOF_MARKER

# Make the temp script executable
chmod +x "$TEMP_SCRIPT"

# Get script name for display
SCRIPT_DISPLAY_NAME=$(basename "__ORIGINAL_SCRIPT_PLACEHOLDER__")

# Open Ghostty with the script
echo "🚀 Opening Ghostty window for: $SCRIPT_DISPLAY_NAME"
echo "📝 Running ghostified version..."

open -a Ghostty "$TEMP_SCRIPT"

# Clean up temp script after delay
(sleep 10 && rm -f "$TEMP_SCRIPT") &
GHOSTTIFY_EOF_MARKER

# Replace placeholders with actual values using unique markers to avoid conflicts
sed -i '' "s|__ORIGINAL_SCRIPT_PLACEHOLDER__|$ORIGINAL_SCRIPT_ESCAPED|g" "$OUTPUT_SCRIPT"
sed -i '' "s|__SCRIPT_TITLE_PLACEHOLDER__|$SCRIPT_TITLE_ESCAPED|g" "$OUTPUT_SCRIPT"

# Handle script content separately to avoid issues with special characters
# Create a temporary file with the script content
TEMP_CONTENT="/tmp/script_content_$(date +%Y%m%d_%H%M%S).tmp"
echo "$SCRIPT_CONTENT" > "$TEMP_CONTENT"

# Use a while loop approach for script content replacement
# This is more reliable than trying to pass multiline content to awk
while IFS= read -r line; do
    if [[ "$line" == "__SCRIPT_CONTENT_PLACEHOLDER__" ]]; then
        cat "$TEMP_CONTENT"
    else
        echo "$line"
    fi
done < "$OUTPUT_SCRIPT" > "${OUTPUT_SCRIPT}.tmp" && mv "${OUTPUT_SCRIPT}.tmp" "$OUTPUT_SCRIPT"

# Clean up temp content file
rm -f "$TEMP_CONTENT"

# Make the output script executable
chmod +x "$OUTPUT_SCRIPT"

echo -e "${GREEN}✅ Ghostified script created successfully!${NC}"
echo -e "${CYAN}📁 Output file: $OUTPUT_SCRIPT${NC}"
echo -e "${BLUE}📁 Original preserved: $ORIGINAL_SCRIPT${NC}"
echo ""
echo -e "${PURPLE}🎯 You can now run: $OUTPUT_SCRIPT${NC}"

# Provide tips based on detected patterns
if [ "$HAS_RELATIVE_SOURCES" = true ] || [ "$HAS_CD_COMMANDS" = true ] || [ "$HAS_COMPLEX_PATHS" = true ] || [ "$HAS_BASH_SOURCE" = true ]; then
    echo ""
    echo -e "${YELLOW}💡 Tips for best results:${NC}"
    
    if [ "$HAS_RELATIVE_SOURCES" = true ]; then
        echo -e "${CYAN}   - Ensure all sourced files are accessible from: $SCRIPT_DIR${NC}"
    fi
    
    if [ "$HAS_CD_COMMANDS" = true ]; then
        echo -e "${CYAN}   - The script will start in its original directory${NC}"
    fi
    
    if [ "$HAS_COMPLEX_PATHS" = true ]; then
        echo -e "${CYAN}   - Test the ghostified script with your typical use cases${NC}"
    fi
    
    if [ "$HAS_BASH_SOURCE" = true ]; then
        echo -e "${CYAN}   - BASH_SOURCE is simulated; check \$GHOSTTIFY_ORIGINAL_SOURCE if needed${NC}"
    fi
fi

show_notification "✅ $(basename "$SCRIPT_NAME") ghostified successfully!"

echo ""
echo -e "${YELLOW}Press any key to close this window...${NC}"
read -n 1 -s

# Clean up temp script
rm -f "$0"
SCRIPT_EOF

# Make the temp script executable
chmod +x "$TEMP_SCRIPT"

# Show initial notification and info
echo "👻 Opening Ghostty window for Ghosttify..."
echo "📝 Interactive ghostification experience loading..."
show_notification "👻 Opening Ghosttify interface..."

# Open Ghostty with the script
open -a Ghostty "$TEMP_SCRIPT"

# Clean up temp script after delay
(sleep 15 && rm -f "$TEMP_SCRIPT") &