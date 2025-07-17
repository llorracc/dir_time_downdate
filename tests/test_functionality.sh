#!/usr/bin/env zsh

# Test suite for dir-time-downdate functionality
# This script tests various scenarios and edge cases

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name - $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Global cleanup function
cleanup_all() {
    echo -e "${YELLOW}Cleaning up test directory...${NC}"
    rm -rf /tmp/dir-time-downdate/
}

# Main test execution
main() {
    echo -e "${YELLOW}Starting dir-time-downdate test suite...${NC}"
    echo -e "${YELLOW}Test directory: /tmp/dir-time-downdate/${NC}"
    echo
    
    # Set up cleanup trap
    trap cleanup_all EXIT
    
    # Find the script - try current directory first, then relative to test location
    if [[ -f "bin/dir-time-downdate" ]]; then
        SCRIPT_PATH="$(pwd)/bin/dir-time-downdate"
    elif [[ -f "$(dirname "$0")/../bin/dir-time-downdate" ]]; then
        SCRIPT_PATH="$(cd "$(dirname "$0")/.." && pwd)/bin/dir-time-downdate"
    else
        echo -e "${RED}Error: Could not find dir-time-downdate script${NC}"
        exit 1
    fi
    
    # Verify script exists
    echo -e "${YELLOW}Script path: $SCRIPT_PATH${NC}"
    if [[ ! -f "$SCRIPT_PATH" ]]; then
        echo -e "${RED}Error: Script not found at $SCRIPT_PATH${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Script found${NC}"
    echo
    
    # Test 1: Basic syntax check
    echo -e "${YELLOW}Testing syntax...${NC}"
    if zsh -n "$SCRIPT_PATH" 2>/dev/null; then
        print_result "Script syntax check" "PASS"
    else
        print_result "Script syntax check" "FAIL" "Syntax check failed"
    fi
    
    # Test 2: Help functionality
    echo -e "${YELLOW}Testing help functionality...${NC}"
    if "$SCRIPT_PATH" --help >/dev/null 2>&1; then
        print_result "Help option works" "PASS"
    else
        print_result "Help option works" "FAIL" "Help command failed"
    fi
    
    # Test help format
    if "$SCRIPT_PATH" --help 2>/dev/null | grep -q "Usage:"; then
        print_result "Help format check" "PASS"
    else
        print_result "Help format check" "FAIL" "Help doesn't show usage"
    fi
    
    # Test 3: Basic directory processing
    echo -e "${YELLOW}Testing basic directory processing...${NC}"
    TEST_DIR="/tmp/dir-time-downdate/basic_test"
    mkdir -p "$TEST_DIR"/{sub1,sub2}
    echo "content1" > "$TEST_DIR"/file1.txt
    echo "content2" > "$TEST_DIR"/sub1/file2.txt
    echo "content3" > "$TEST_DIR"/sub2/file3.txt
    
    echo "Running: $SCRIPT_PATH --verbose --non-interactive $TEST_DIR"
    if "$SCRIPT_PATH" --verbose --non-interactive "$TEST_DIR"; then
        print_result "Basic directory processing" "PASS"
    else
        print_result "Basic directory processing" "FAIL" "Processing failed"
    fi
    
    # Test 4: Empty directory handling
    echo -e "${YELLOW}Testing empty directory handling...${NC}"
    EMPTY_TEST_DIR="/tmp/dir-time-downdate/empty_test"
    mkdir -p "$EMPTY_TEST_DIR"/{empty1,empty2,empty3}
    
    echo "Running: $SCRIPT_PATH --verbose --non-interactive $EMPTY_TEST_DIR"
    if "$SCRIPT_PATH" --verbose --non-interactive "$EMPTY_TEST_DIR"; then
        print_result "Empty directory processing" "PASS"
    else
        print_result "Empty directory processing" "FAIL" "Empty directory processing failed"
    fi
    
    # Test 5: System file cleanup
    echo -e "${YELLOW}Testing system file cleanup...${NC}"
    CLEANUP_TEST_DIR="/tmp/dir-time-downdate/cleanup_test"
    mkdir -p "$CLEANUP_TEST_DIR"/subdir
    echo "content" > "$CLEANUP_TEST_DIR"/file.txt
    
    # Create system files that should be cleaned up
    touch "$CLEANUP_TEST_DIR"/.DS_Store
    touch "$CLEANUP_TEST_DIR"/subdir/.DS_Store
    
    echo "Running: $SCRIPT_PATH --verbose --non-interactive $CLEANUP_TEST_DIR"
    if "$SCRIPT_PATH" --verbose --non-interactive "$CLEANUP_TEST_DIR"; then
        if [[ ! -f "$CLEANUP_TEST_DIR"/.DS_Store && ! -f "$CLEANUP_TEST_DIR"/subdir/.DS_Store ]]; then
            print_result "System file cleanup" "PASS"
        else
            print_result "System file cleanup" "FAIL" "System files not cleaned up"
        fi
    else
        print_result "System file cleanup" "FAIL" "Cleanup processing failed"
    fi
    
    # Test 6: Non-interactive mode
    echo -e "${YELLOW}Testing non-interactive mode...${NC}"
    NONINT_TEST_DIR="/tmp/dir-time-downdate/noninteractive_test"
    mkdir -p "$NONINT_TEST_DIR"
    echo "content" > "$NONINT_TEST_DIR"/file.txt
    
    echo "Running: timeout 10 $SCRIPT_PATH --verbose --non-interactive $NONINT_TEST_DIR"
    if timeout 10 "$SCRIPT_PATH" --verbose --non-interactive "$NONINT_TEST_DIR"; then
        print_result "Non-interactive mode" "PASS"
    else
        print_result "Non-interactive mode" "FAIL" "Non-interactive mode failed or hung"
    fi
    
    # Test 7: Invalid directory handling
    echo -e "${YELLOW}Testing invalid directory handling...${NC}"
    echo "Running: $SCRIPT_PATH --verbose --non-interactive /nonexistent/directory (should fail)"
    if ! "$SCRIPT_PATH" --verbose --non-interactive /nonexistent/directory >/dev/null 2>&1; then
        print_result "Invalid directory handling" "PASS"
    else
        print_result "Invalid directory handling" "FAIL" "Should fail with non-existent directory"
    fi
    
    # Test 8: Verbose mode output
    echo -e "${YELLOW}Testing verbose mode...${NC}"
    VERBOSE_TEST_DIR="/tmp/dir-time-downdate/verbose_test"
    mkdir -p "$VERBOSE_TEST_DIR"
    echo "content" > "$VERBOSE_TEST_DIR"/file.txt
    
    echo "Running: $SCRIPT_PATH --verbose --non-interactive $VERBOSE_TEST_DIR"
    output=$("$SCRIPT_PATH" --verbose --non-interactive "$VERBOSE_TEST_DIR" 2>&1)
    echo "Output received: $output"
    if echo "$output" | grep -q "Processing\|directory\|Deleted\|Created"; then
        print_result "Verbose mode output" "PASS"
    else
        print_result "Verbose mode output" "FAIL" "Verbose mode didn't produce expected output"
    fi
    
    # Print summary
    echo
    echo -e "${YELLOW}Test Summary:${NC}"
    echo "  Tests run: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed${NC}"
        exit 1
    fi
}

# Run tests
main "$@"
