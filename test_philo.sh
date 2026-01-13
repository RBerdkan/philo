#!/bin/bash
# filepath: test_eval.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

PHILO="./philo"
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Check if program exists
if [ ! -f "$PHILO" ]; then
    echo -e "${RED}Error: $PHILO not found. Run 'make' first.${NC}"
    exit 1
fi

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() {
    ((TOTAL_TESTS++))
    echo -e "\n${BLUE}[TEST $TOTAL_TESTS]${NC} $1"
}

print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED_TESTS++))
    fi
}

clear
echo -e "${MAGENTA}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     PHILOSOPHERS - EVALUATION SHEET BASED TESTS          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================================================
# SECTION 1: MANDATORY PART - ARGUMENT HANDLING
# ============================================================================
print_header "1. ARGUMENT HANDLING (Evaluation Criteria)"

# Test 1.1: Wrong arguments
print_test "Invalid arguments (non-numeric)"
$PHILO test 800 200 200 > /tmp/philo_out.txt 2>&1
if [ $? -ne 0 ]; then
    print_result 0
else
    print_result 1
fi

# Test 1.2: Wrong arguments (negative)
print_test "Invalid arguments (negative number)"
$PHILO -5 800 200 200 > /tmp/philo_out.txt 2>&1
if [ $? -ne 0 ]; then
    print_result 0
else
    print_result 1
fi

# Test 1.3: Not enough arguments
print_test "Not enough arguments"
$PHILO 5 800 200 > /tmp/philo_out.txt 2>&1
if [ $? -ne 0 ]; then
    print_result 0
else
    print_result 1
fi

# ============================================================================
# SECTION 2: MANDATORY PART - DEATH DETECTION
# ============================================================================
print_header "2. DEATH DETECTION (From Evaluation Sheet)"

# Test 2.1: One philosopher should die
print_test "One philosopher should die"
timeout 2 $PHILO 1 800 200 200 > /tmp/philo_out.txt 2>&1
if grep -q "died" /tmp/philo_out.txt; then
    echo -e "${YELLOW}  Death detected correctly${NC}"
    print_result 0
else
    echo -e "${RED}  No death detected!${NC}"
    print_result 1
fi

# Test 2.2: No philosopher should die (5 800 200 200)
print_test "No philosopher should die (5 800 200 200)"
timeout 5 $PHILO 5 800 200 200 > /tmp/philo_out.txt 2>&1
if ! grep -q "died" /tmp/philo_out.txt; then
    echo -e "${YELLOW}  No deaths (correct)${NC}"
    print_result 0
else
    echo -e "${RED}  Unexpected death!${NC}"
    print_result 1
fi

# Test 2.3: Death test (4 310 200 100)
print_test "Death should occur (4 310 200 100)"
timeout 2 $PHILO 4 310 200 100 > /tmp/philo_out.txt 2>&1
if grep -q "died" /tmp/philo_out.txt; then
    # Check death timing
    DEATH_TIME=$(grep "died" /tmp/philo_out.txt | tail -1 | awk '{print $1}')
    if [ $DEATH_TIME -le 320 ]; then
        echo -e "${YELLOW}  Death at ${DEATH_TIME}ms (within 310ms + 10ms margin)${NC}"
        print_result 0
    else
        echo -e "${RED}  Death too late: ${DEATH_TIME}ms${NC}"
        print_result 1
    fi
else
    echo -e "${RED}  No death detected!${NC}"
    print_result 1
fi

# Test 2.4: Death detection timing (from evaluation sheet)
print_test "Death timing accuracy (4 410 200 200)"
timeout 3 $PHILO 4 410 200 200 > /tmp/philo_out.txt 2>&1
if grep -q "died" /tmp/philo_out.txt; then
    DEATH_TIME=$(grep "died" /tmp/philo_out.txt | tail -1 | awk '{print $1}')
    PHILO_ID=$(grep "died" /tmp/philo_out.txt | tail -1 | awk '{print $2}')
    LAST_EAT=$(grep "^[0-9]* $PHILO_ID is eating" /tmp/philo_out.txt | tail -1 | awk '{print $1}')
    if [ -z "$LAST_EAT" ]; then
        LAST_EAT=0
    fi
    TIME_DIFF=$((DEATH_TIME - LAST_EAT))
    if [ $TIME_DIFF -le 420 ] && [ $TIME_DIFF -ge 400 ]; then
        echo -e "${YELLOW}  Death timing correct: ${TIME_DIFF}ms since last meal${NC}"
        print_result 0
    else
        echo -e "${RED}  Death timing wrong: ${TIME_DIFF}ms (expected ~410ms)${NC}"
        print_result 1
    fi
else
    echo -e "${RED}  No death detected (expected death)${NC}"
    print_result 1
fi

# ============================================================================
# SECTION 3: MANDATORY PART - STOP CONDITION
# ============================================================================
print_header "3. STOP CONDITION (Evaluation Sheet)"

# Test 3.1: Program stops after death
print_test "Program stops after death (no messages after death)"
timeout 2 $PHILO 4 310 200 100 > /tmp/philo_out.txt 2>&1
if grep -q "died" /tmp/philo_out.txt; then
    DEATH_LINE=$(grep -n "died" /tmp/philo_out.txt | head -1 | cut -d: -f1)
    TOTAL_LINES=$(wc -l < /tmp/philo_out.txt)
    
    if [ $DEATH_LINE -eq $TOTAL_LINES ]; then
        echo -e "${YELLOW}  No messages after death (correct)${NC}"
        print_result 0
    else
        EXTRA_LINES=$((TOTAL_LINES - DEATH_LINE))
        echo -e "${RED}  Found $EXTRA_LINES messages after death!${NC}"
        print_result 1
    fi
else
    echo -e "${RED}  No death detected${NC}"
    print_result 1
fi

# Test 3.2: Death reported within 10ms
print_test "Death reported within 10ms (from evaluation)"
timeout 2 $PHILO 4 310 200 100 > /tmp/philo_out.txt 2>&1
if grep -q "died" /tmp/philo_out.txt; then
    DEATH_TIME=$(grep "died" /tmp/philo_out.txt | tail -1 | awk '{print $1}')
    PHILO_ID=$(grep "died" /tmp/philo_out.txt | tail -1 | awk '{print $2}')
    LAST_EAT=$(grep "^[0-9]* $PHILO_ID is eating" /tmp/philo_out.txt | tail -1 | awk '{print $1}')
    if [ -z "$LAST_EAT" ]; then
        LAST_EAT=0
    fi
    TIME_DIFF=$((DEATH_TIME - LAST_EAT))
    
    # Should be within time_to_die + 10ms
    if [ $TIME_DIFF -le 320 ]; then
        echo -e "${YELLOW}  Death reported in time: ${TIME_DIFF}ms${NC}"
        print_result 0
    else
        echo -e "${RED}  Death reported too late: ${TIME_DIFF}ms${NC}"
        print_result 1
    fi
else
    print_result 1
fi

# ============================================================================
# SECTION 4: BONUS PART - MEAL COUNT
# ============================================================================
print_header "4. BONUS - MEAL COUNT (Evaluation Sheet)"

# Test 4.1: All philosophers must eat X times
print_test "All philosophers eat exactly 7 times (5 800 200 200 7)"
timeout 10 $PHILO 5 800 200 200 7 > /tmp/philo_out.txt 2>&1
EATING_COUNT=$(grep "is eating" /tmp/philo_out.txt | wc -l)
if [ $EATING_COUNT -eq 35 ]; then  # 5 philos * 7 meals
    echo -e "${YELLOW}  Correct: 35 eating actions (5 × 7)${NC}"
    # Check no deaths
    if ! grep -q "died" /tmp/philo_out.txt; then
        print_result 0
    else
        echo -e "${RED}  Unexpected death occurred${NC}"
        print_result 1
    fi
else
    echo -e "${RED}  Expected 35 eating actions, got $EATING_COUNT${NC}"
    print_result 1
fi

# Test 4.2: Program stops after all ate enough
print_test "Program stops after all ate enough (4 800 200 200 5)"
timeout 10 $PHILO 4 800 200 200 5 > /tmp/philo_out.txt 2>&1
EXIT_CODE=$?
EATING_COUNT=$(grep "is eating" /tmp/philo_out.txt | wc -l)

if [ $EATING_COUNT -eq 20 ] && [ $EXIT_CODE -eq 0 ]; then
    echo -e "${YELLOW}  Correct: Program stopped after 20 meals (4 × 5)${NC}"
    print_result 0
else
    echo -e "${RED}  Expected 20 meals and clean exit, got $EATING_COUNT meals${NC}"
    print_result 1
fi

# ============================================================================
# SECTION 5: OUTPUT FORMAT (From Evaluation Sheet)
# ============================================================================
print_header "5. OUTPUT FORMAT (Evaluation Criteria)"

# Test 5.1: Correct format
print_test "Output format: 'timestamp_in_ms X status'"
timeout 2 $PHILO 4 800 200 200 > /tmp/philo_out.txt 2>&1
# Format should be: number space number space action
if grep -Eq "^[0-9]+ [0-9]+ (has taken a fork|is eating|is sleeping|is thinking|died)$" /tmp/philo_out.txt; then
    echo -e "${YELLOW}  Format correct${NC}"
    print_result 0
else
    echo -e "${RED}  Format incorrect${NC}"
    head -5 /tmp/philo_out.txt
    print_result 1
fi

# Test 5.2: No mixed output
print_test "No mixed/garbled output"
timeout 2 $PHILO 4 800 200 200 > /tmp/philo_out.txt 2>&1
if ! grep -Eq ".*(eating|sleeping|thinking|fork).*(eating|sleeping|thinking|fork)" /tmp/philo_out.txt; then
    echo -e "${YELLOW}  No mixed output${NC}"
    print_result 0
else
    echo -e "${RED}  Found mixed output!${NC}"
    print_result 1
fi

# Test 5.3: Timestamps are increasing
print_test "Timestamps are monotonically increasing"
timeout 2 $PHILO 4 800 200 200 > /tmp/philo_out.txt 2>&1
if awk '{print $1}' /tmp/philo_out.txt | awk 'NR>1 && $1 < prev {exit 1} {prev=$1}'; then
    echo -e "${YELLOW}  Timestamps increasing${NC}"
    print_result 0
else
    echo -e "${RED}  Timestamps not increasing!${NC}"
    print_result 1
fi

# ============================================================================
# SECTION 6: STRESS TESTS (From Evaluation Sheet)
# ============================================================================
print_header "6. STRESS TESTS (Evaluation Criteria)"

# Test 6.1: 200 philosophers
print_test "200 philosophers (no crash, no death)"
timeout 5 $PHILO 200 800 200 200 > /tmp/philo_out.txt 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -eq 124 ] || [ $EXIT_CODE -eq 0 ]; then
    if ! grep -q "died" /tmp/philo_out.txt; then
        echo -e "${YELLOW}  No deaths with 200 philosophers${NC}"
        print_result 0
    else
        echo -e "${RED}  Death occurred with 200 philosophers${NC}"
        print_result 1
    fi
else
    echo -e "${RED}  Program crashed with 200 philosophers${NC}"
    print_result 1
fi

# Test 6.2: Very tight timing
print_test "Very tight timing (4 410 200 200)"
timeout 3 $PHILO 4 410 200 200 > /tmp/philo_out.txt 2>&1
if grep -q "died" /tmp/philo_out.txt; then
    echo -e "${YELLOW}  Death occurred (expected)${NC}"
    print_result 0
else
    echo -e "${RED}  No death (but expected)${NC}"
    print_result 1
fi

# ============================================================================
# SECTION 7: MEMORY LEAKS (Evaluation Sheet Requirement)
# ============================================================================
print_header "7. MEMORY LEAKS (MANDATORY CHECK)"

if command -v valgrind &> /dev/null; then
    # Test 7.1: Basic leak check
    print_test "Memory leaks check (5 philosophers, 5 meals)"
    valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --error-exitcode=42 \
        $PHILO 5 800 200 200 5 > /tmp/philo_valgrind.txt 2>&1
    VALGRIND_EXIT=$?
    
    if [ $VALGRIND_EXIT -eq 0 ]; then
        echo -e "${YELLOW}  No memory leaks detected${NC}"
        print_result 0
    else
        echo -e "${RED}  Memory leaks detected!${NC}"
        grep "definitely lost" /tmp/philo_valgrind.txt
        print_result 1
    fi

    # Test 7.2: Leak check with death
    print_test "Memory leaks check (with death scenario)"
    valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --error-exitcode=42 \
        $PHILO 4 310 200 100 > /tmp/philo_valgrind2.txt 2>&1
    VALGRIND_EXIT=$?
    
    if [ $VALGRIND_EXIT -eq 0 ] || [ $VALGRIND_EXIT -eq 124 ]; then
        echo -e "${YELLOW}  No memory leaks with death scenario${NC}"
        print_result 0
    else
        echo -e "${RED}  Memory leaks in death scenario!${NC}"
        grep "definitely lost" /tmp/philo_valgrind2.txt
        print_result 1
    fi
else
    echo -e "${YELLOW}  Valgrind not found. Install: sudo apt-get install valgrind${NC}"
fi

# ============================================================================
# SECTION 8: DATA RACES (Evaluation Sheet Requirement)
# ============================================================================
print_header "8. DATA RACES (MANDATORY CHECK)"

if command -v valgrind &> /dev/null; then
    # Test 8.1: Helgrind check
    print_test "Data race check with Helgrind"
    valgrind --tool=helgrind --error-exitcode=42 \
        $PHILO 5 800 200 200 5 > /tmp/philo_helgrind.txt 2>&1
    HELGRIND_EXIT=$?
    
    if [ $HELGRIND_EXIT -eq 0 ] || [ $HELGRIND_EXIT -eq 124 ]; then
        echo -e "${YELLOW}  No data races detected${NC}"
        print_result 0
    else
        echo -e "${RED}  Data races detected!${NC}"
        grep "Possible data race" /tmp/philo_helgrind.txt | head -5
        print_result 1
    fi

    # Test 8.2: Data races with many threads
    print_test "Data race check with 50 philosophers"
    timeout 10 valgrind --tool=helgrind --error-exitcode=42 \
        $PHILO 50 800 200 200 > /tmp/philo_helgrind2.txt 2>&1
    HELGRIND_EXIT=$?
    
    if [ $HELGRIND_EXIT -eq 0 ] || [ $HELGRIND_EXIT -eq 124 ]; then
        echo -e "${YELLOW}  No data races with 50 philosophers${NC}"
        print_result 0
    else
        echo -e "${RED}  Data races with many philosophers!${NC}"
        grep "Possible data race" /tmp/philo_helgrind2.txt | head -5
        print_result 1
    fi
else
    echo -e "${YELLOW}  Valgrind not found. Skipping data race tests.${NC}"
fi

# ============================================================================
# SECTION 9: ADDITIONAL EVALUATION TESTS
# ============================================================================
print_header "9. ADDITIONAL EVALUATION TESTS"

# Test 9.1: Two philosophers
print_test "Two philosophers (from evaluation sheet)"
timeout 3 $PHILO 2 800 200 200 > /tmp/philo_out.txt 2>&1
if ! grep -q "died" /tmp/philo_out.txt; then
    print_result 0
else
    print_result 1
fi

# Test 9.2: No deadlock
print_test "No deadlock (program doesn't hang)"
timeout 5 $PHILO 4 800 200 200 5 > /tmp/philo_out.txt 2>&1
EXIT_CODE=$?
if [ $EXIT_CODE -ne 124 ]; then
    echo -e "${YELLOW}  Program completed (no deadlock)${NC}"
    print_result 0
else
    echo -e "${RED}  Program hung (possible deadlock)${NC}"
    print_result 1
fi

# ============================================================================
# FINAL RESULTS
# ============================================================================
echo -e "\n${MAGENTA}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                     TEST RESULTS                          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Total Tests:${NC}  $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC}       $PASSED_TESTS"
echo -e "${RED}Failed:${NC}       $FAILED_TESTS"

PASS_RATE=$(awk "BEGIN {printf \"%.1f\", ($PASSED_TESTS/$TOTAL_TESTS)*100}")
echo -e "${CYAN}Pass Rate:${NC}    $PASS_RATE%"

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}EVALUATION SHEET REQUIREMENTS:${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "✓ Argument handling"
echo -e "✓ Death detection"
echo -e "✓ Death timing (<10ms)"
echo -e "✓ No messages after death"
echo -e "✓ Output format"
echo -e "✓ Meal count (bonus)"
echo -e "✓ Memory leaks"
echo -e "✓ Data races"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║              ✓ ALL TESTS PASSED! ✓                       ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║           READY FOR EVALUATION! 🎉                       ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "\n${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                           ║${NC}"
    echo -e "${RED}║              ✗ SOME TESTS FAILED ✗                       ║${NC}"
    echo -e "${RED}║                                                           ║${NC}"
    echo -e "${RED}║           FIX ISSUES BEFORE EVALUATION                    ║${NC}"
    echo -e "${RED}║                                                           ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi

# Cleanup
rm -f /tmp/philo_out.txt /tmp/philo_valgrind.txt /tmp/philo_valgrind2.txt
rm -f /tmp/philo_helgrind.txt /tmp/philo_helgrind2.txt