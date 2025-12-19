#!/usr/bin/env zsh

# =============================================================================
# parse-test-coverage.zsh
# =============================================================================
# Zsh function to run the parse-test-coverage.ts TypeScript file
# 
# Usage:
#   1. Save this file to ~/bin/parse-test-coverage.zsh
#   2. Make executable: chmod +x ~/bin/parse-test-coverage.zsh
#   3. Add to PATH or create alias in ~/.zshrc:
#      alias parse-coverage='~/bin/parse-test-coverage.zsh'
#   4. Run from any directory containing TEST_COVERAGE.txt
# =============================================================================

parse_test_coverage() {
    local SCRIPT_DIR="$HOME/bin"
    local SCRIPT_FILE="$SCRIPT_DIR/parse-test-coverage.ts"
    local INPUT_FILE="TEST_COVERAGE.txt"
    local OUTPUT_FILE="TEST_COVERAGE_PARSED.md"

    # Check if input file exists in current directory
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "❌ Error: $INPUT_FILE not found in current directory"
        echo ""
        echo "Please run your coverage first:"
        echo "  npm run test:coverage > TEST_COVERAGE.txt 2>&1"
        return 1
    fi

    # Check if TypeScript file exists
    if [[ ! -f "$SCRIPT_FILE" ]]; then
        echo "❌ Error: $SCRIPT_FILE not found"
        echo ""
        echo "Please copy parse-test-coverage.ts to ~/bin/"
        return 1
    fi

    # Try tsx first (faster), fall back to ts-node
    if command -v tsx &> /dev/null; then
        echo "📊 Parsing test coverage with tsx..."
        tsx "$SCRIPT_FILE"
    elif command -v npx &> /dev/null; then
        echo "📊 Parsing test coverage with npx tsx..."
        npx tsx "$SCRIPT_FILE"
    elif command -v ts-node &> /dev/null; then
        echo "📊 Parsing test coverage with ts-node..."
        ts-node "$SCRIPT_FILE"
    else
        echo "❌ Error: No TypeScript runner found"
        echo ""
        echo "Please install one of the following:"
        echo "  npm install -g tsx           (recommended - fastest)"
        echo "  npm install -g ts-node       (alternative)"
        return 1
    fi

    # Check if output was created
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo ""
        echo "✅ Success! Created $OUTPUT_FILE"
        echo ""
        echo "View in VSCode:"
        echo "  code $OUTPUT_FILE"
    else
        echo ""
        echo "⚠️  Warning: $OUTPUT_FILE was not created"
        return 1
    fi
}

# If sourced, define the function; if executed, run it
if [[ "${(%):-%x}" == "${0}" ]]; then
    # Script is being executed directly
    parse_test_coverage "$@"
fi
