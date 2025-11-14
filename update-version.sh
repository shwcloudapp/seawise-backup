#!/bin/bash
# update-version.sh - Update Helm chart version in all documentation files
#
# Usage: ./update-version.sh 1.5.6 1.5.7

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 OLD_VERSION NEW_VERSION"
    echo ""
    echo "Example: $0 1.5.5 1.5.6"
    echo ""
    echo "This script will:"
    echo "  1. Update Chart.yaml version"
    echo "  2. Update all documentation files"
    echo "  3. Update example values files"
    exit 1
}

# Check arguments
if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Wrong number of arguments${NC}"
    usage
fi

OLD_VERSION="$1"
NEW_VERSION="$2"

# Validate version format (x.y.z)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Use x.y.z (e.g., 1.5.6)${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Updating Seawise Dashboard from v${OLD_VERSION} to v${NEW_VERSION}${NC}"
echo ""

# List of files to update
FILES=(
    "README.md"
    "INSTALL.md"
    "RANCHER-INSTALL.md"
    "OPENSHIFT-INSTALL.md"
    "seawise-dashboard/Chart.yaml"
    "seawise-dashboard/templates/NOTES.txt"
    "seawise-dashboard/values-examples/rancher-traefik-example.yaml"
    "seawise-dashboard/values-examples/rancher-nginx-example.yaml"
    "seawise-dashboard/values-examples/openshift-example.yaml"
    "seawise-dashboard/values-examples/kubernetes-example.yaml"
)

# Counter for updated files
updated=0
skipped=0

# Update each file
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        # Check if file contains the old version
        if grep -q "$OLD_VERSION" "$file"; then
            # macOS uses sed -i '' while Linux uses sed -i
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$OLD_VERSION/$NEW_VERSION/g" "$file"
            else
                sed -i "s/$OLD_VERSION/$NEW_VERSION/g" "$file"
            fi
            echo -e "${GREEN}✅ Updated: $file${NC}"
            ((updated++))
        else
            echo -e "${YELLOW}⏭️  Skipped: $file (no old version found)${NC}"
            ((skipped++))
        fi
    else
        echo -e "${RED}❌ Not found: $file${NC}"
    fi
done

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Version update complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "  Updated files: ${GREEN}${updated}${NC}"
echo -e "  Skipped files: ${YELLOW}${skipped}${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "  1. Review changes: ${GREEN}git diff${NC}"
echo -e "  2. Package chart: ${GREEN}helm package seawise-dashboard${NC}"
echo -e "  3. Commit changes: ${GREEN}git add . && git commit -m \"chore: bump version to ${NEW_VERSION}\"${NC}"
echo -e "  4. Create tag: ${GREEN}git tag v${NEW_VERSION} && git push origin v${NEW_VERSION}${NC}"
echo -e "  5. Create release: ${GREEN}gh release create v${NEW_VERSION} seawise-dashboard-${NEW_VERSION}.tgz${NC}"
echo ""
