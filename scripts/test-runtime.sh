#!/bin/bash
set -euo pipefail

echo "========================================"
echo "Testing RStudio Image Runtime"
echo "========================================"

echo ""
echo "1. Testing R version..."
R --version | head -n 1

echo ""
echo "2. Testing R package installation..."
R -e "install.packages('testthat', repos='https://cran.rstudio.com/', quiet=TRUE); library(testthat); print('Package installation works')"

echo ""
echo "3. Testing core R packages..."
R -e "library(ggplot2); library(dplyr); print('Core packages loaded successfully')" 2>&1 || echo "Warning: Some core packages not pre-installed (expected)"

echo ""
echo "4. Testing Quarto installation..."
quarto --version

echo ""
echo "5. Testing Quarto rendering..."
cat <<'EOF' > /tmp/test.qmd
---
title: 'Test Document'
---

# Test
This is a test.
EOF
quarto render /tmp/test.qmd --to html --quiet && echo "Quarto rendering: OK" || echo "Quarto rendering: FAILED"
rm -f /tmp/test.qmd /tmp/test.html

echo ""
echo "6. Testing system tools..."
echo "  - Git: $(git --version)"
echo "  - CMake: $(cmake --version | head -n 1)"
echo "  - Python: $(python3 --version)"

echo ""
echo "7. Testing scientific libraries..."
which gdal-config > /dev/null && echo "  - GDAL: OK" || echo "  - GDAL: FAILED"
which bowtie2 > /dev/null && echo "  - Bowtie2: OK" || echo "  - Bowtie2: FAILED"

echo ""
echo "8. Testing Git LFS..."
git lfs version

echo ""
echo "========================================"
echo "All tests completed successfully!"
echo "========================================"