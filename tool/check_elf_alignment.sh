#!/bin/bash

# Script to check if ELF binaries in APK/AAB are aligned for 16KB page size
# Usage: ./check_elf_alignment.sh path/to/your-app.apk

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

APK_PATH=$1

if [ -z "$APK_PATH" ]; then
    echo -e "${RED}Error: Please provide path to APK or AAB file${NC}"
    echo "Usage: $0 path/to/your-app.apk"
    exit 1
fi

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}Error: File not found: $APK_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking ELF alignment for 16KB page size...${NC}\n"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract APK/AAB
echo "Extracting $APK_PATH..."
unzip -q "$APK_PATH" -d "$TEMP_DIR"

# Find all .so files
SO_FILES=$(find "$TEMP_DIR" -name "*.so")

if [ -z "$SO_FILES" ]; then
    echo -e "${YELLOW}No .so files found in the package${NC}"
    exit 0
fi

FAILED=0
PASSED=0

echo -e "\nChecking alignment of native libraries:\n"

for SO_FILE in $SO_FILES; do
    RELATIVE_PATH=$(echo "$SO_FILE" | sed "s|$TEMP_DIR/||")
    
    # Check if file is ELF
    if file "$SO_FILE" | grep -q "ELF"; then
        # Get alignment using readelf
        ALIGNMENT=$(readelf -l "$SO_FILE" 2>/dev/null | grep "LOAD" | head -1 | awk '{print $6}')
        
        if [ -z "$ALIGNMENT" ]; then
            echo -e "${YELLOW}⚠ Could not determine alignment: $RELATIVE_PATH${NC}"
            continue
        fi
        
        # Convert hex to decimal if needed
        if [[ $ALIGNMENT == 0x* ]]; then
            ALIGNMENT=$((ALIGNMENT))
        fi
        
        # Check if alignment is sufficient for 16KB (16384 bytes)
        if [ "$ALIGNMENT" -ge 16384 ]; then
            echo -e "${GREEN}✓ PASS: $RELATIVE_PATH (alignment: $ALIGNMENT)${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ FAIL: $RELATIVE_PATH (alignment: $ALIGNMENT, required: 16384)${NC}"
            ((FAILED++))
        fi
    fi
done

echo -e "\n${YELLOW}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════${NC}\n"

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Some libraries are NOT compatible with 16KB page size!${NC}"
    echo -e "${YELLOW}Action required:${NC}"
    echo "  1. Update dependencies to versions that support 16KB page size"
    echo "  2. Rebuild native libraries with -Wl,-z,max-page-size=16384 linker flag"
    echo "  3. Update NDK to r27 or higher"
    exit 1
else
    echo -e "${GREEN}✅ All libraries are compatible with 16KB page size!${NC}"
    exit 0
fi
