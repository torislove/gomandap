#!/usr/bin/env bash

# Exit on any error
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${CYAN}==========================================================${NC}"
echo -e "${YELLOW}👑       GOMANDAP TRIPLE-APP SYSTEM ORCHESTRATOR        👑${NC}"
echo -e "${CYAN}==========================================================${NC}"

# Parse parameters
INSTALL=false
CLEAN=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--install) INSTALL=true ;;
        -c|--clean) CLEAN=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [ ! -d "android" ]; then
    echo -e "${RED}❌ Error: 'android' directory not found!${NC}"
    exit 1
fi

cd android

# Build tasks
TASKS=()

if [ "$CLEAN" = true ]; then
    echo -e "${CYAN}🧼 Requesting clean build...${NC}"
    TASKS+=("clean")
fi

if [ "$INSTALL" = true ]; then
    echo -e "${MAGENTA}📲 Requesting compilation and device installation...${NC}"
    TASKS+=("installDebug")
else
    echo -e "${GREEN}🏗️ Requesting compilation (assemble debug targets)...${NC}"
    TASKS+=("assembleDebug")
fi

echo -e "${YELLOW}Running: ./gradlew ${TASKS[*]}${NC}"
echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"

if ./gradlew "${TASKS[@]}"; then
    echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"
    echo -e "${GREEN}🎉 SUCCESS: All operations completed beautifully!${NC}"
    if [ "$INSTALL" = true ]; then
        echo -e "${GREEN}📱 GoMandap Client, GmAdmin, and GoMandap Vendor apps installed!${NC}"
    else
        echo -e "${GREEN}📦 Debug APKs created for Client, Admin, and Vendor applications!${NC}"
    fi
else
    echo -e "${CYAN}──────────────────────────────────────────────────────────${NC}"
    echo -e "${RED}❌ ERROR: Gradle execution failed!${NC}"
    exit 1
fi

cd ..
echo -e "${CYAN}==========================================================${NC}"
