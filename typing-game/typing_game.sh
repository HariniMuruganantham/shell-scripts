#!/bin/bash

###############################################################################
# Project: Typing Game Shell Script
# Purpose: A terminal-based typing game to improve typing speed and accuracy
# Author: Harini Muruganantham
# Version: 1.0
# Date: 5th January 2026
###############################################################################

# ==================================================
# COLORS
# ==================================================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# ==================================================
# FILE PATHS
# ==================================================
SHORT_WORDS="words/short.txt"
MEDIUM_WORDS="words/medium.txt"
LONG_WORDS="words/long.txt"
LEADERBOARD="leaderboard.txt"

# ==================================================
# UI FUNCTIONS
# ==================================================
draw_border() {
  echo -e "${BLUE}=========================================${RESET}"
}

welcome() {
  clear
  draw_border
  echo -e "${CYAN}        SHELL TYPING GAME${RESET}"
  draw_border
  echo "Practice typing with speed and accuracy"
  echo
}

# ==================================================
# DIFFICULTY SELECTION
# ==================================================
select_mode() {
  echo "Select Difficulty Level:"
  echo "1) Easy"
  echo "2) Medium"
  echo "3) Hard"
  read -p "Enter choice: " MODE

  case $MODE in
    1) BASE_TIME=5 ;;
    2) BASE_TIME=4 ;;
    3) BASE_TIME=3 ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
}

# ==================================================
# CATEGORY SELECTION
# ==================================================
select_category() {
  echo
  echo "Select Typing Category:"
  echo "1) Short Words (3–4 letters)"
  echo "2) Medium Words (5–7 letters)"
  echo "3) Long Words (8+ letters)"
  read -p "Enter choice: " CAT

  case $CAT in
    1) WORD_FILE=$SHORT_WORDS; CAT_NAME="Short" ;;
    2) WORD_FILE=$MEDIUM_WORDS; CAT_NAME="Medium" ;;
    3) WORD_FILE=$LONG_WORDS; CAT_NAME="Long" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac

  # Safety check
  if [[ ! -f "$WORD_FILE" ]]; then
    echo "Word file not found: $WORD_FILE"
    exit 1
  fi
}

# ==================================================
# WORD GENERATION
# ==================================================
generate_word() {
  TARGET=$(shuf -n 1 "$WORD_FILE")
  WORD_LEN=${#TARGET}
  TIME_LIMIT=$((BASE_TIME + WORD_LEN / 2))
}

# ==================================================
# GAME LOGIC
# ==================================================
play_game() {
  SCORE=0
  TOTAL=0

  SHORT_TOTAL=0; SHORT_CORRECT=0
  MEDIUM_TOTAL=0; MEDIUM_CORRECT=0
  LONG_TOTAL=0; LONG_CORRECT=0

  START_TIME=$(date +%s)

  while true; do
    clear
    draw_border
    generate_word
    echo -e "Type this word: ${YELLOW}$TARGET${RESET}"
    echo "Time allowed: ${TIME_LIMIT}s"
    draw_border

    read -t $TIME_LIMIT -p "Your input: " INPUT
    READ_STATUS=$?

    TOTAL=$((TOTAL + 1))

    case $CAT_NAME in
      Short)  SHORT_TOTAL=$((SHORT_TOTAL+1)) ;;
      Medium) MEDIUM_TOTAL=$((MEDIUM_TOTAL+1)) ;;
      Long)   LONG_TOTAL=$((LONG_TOTAL+1)) ;;
    esac

    if [[ $READ_STATUS -eq 0 && "${INPUT,,}" == "${TARGET,,}" ]]; then
      echo -e "${GREEN}Correct!${RESET}"
      SCORE=$((SCORE + 1))

      case $CAT_NAME in
        Short)  SHORT_CORRECT=$((SHORT_CORRECT+1)) ;;
        Medium) MEDIUM_CORRECT=$((MEDIUM_CORRECT+1)) ;;
        Long)   LONG_CORRECT=$((LONG_CORRECT+1)) ;;
      esac

      # Adaptive difficulty
      if (( SCORE % 10 == 0 && BASE_TIME > 1 )); then
        BASE_TIME=$((BASE_TIME - 1))
      fi
    elif [[ $READ_STATUS -ne 0 ]]; then
      echo -e "${RED}Time Up!${RESET}"
    else
      echo -e "${RED}Wrong!${RESET}"
    fi

    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))
    WPM=0
    (( ELAPSED > 0 )) && WPM=$((SCORE * 60 / ELAPSED))

    echo
    echo "Score: $SCORE / $TOTAL"
    echo "Live WPM: $WPM"
    sleep 1
  done
}

# ==================================================
# EXIT HANDLER (GRACEFUL EXIT)
# ==================================================
exit_game() {
  END_TIME=$(date +%s)
  ELAPSED=$((END_TIME - START_TIME))
  FINAL_WPM=0
  (( ELAPSED > 0 )) && FINAL_WPM=$((SCORE * 60 / ELAPSED))

  SHORT_ACC=0; MEDIUM_ACC=0; LONG_ACC=0
  (( SHORT_TOTAL > 0 )) && SHORT_ACC=$((SHORT_CORRECT*100/SHORT_TOTAL))
  (( MEDIUM_TOTAL > 0 )) && MEDIUM_ACC=$((MEDIUM_CORRECT*100/MEDIUM_TOTAL))
  (( LONG_TOTAL > 0 )) && LONG_ACC=$((LONG_CORRECT*100/LONG_TOTAL))

  touch "$LEADERBOARD"
  echo "$FINAL_WPM $(date '+%F %T')" >> "$LEADERBOARD"
  BEST=$(sort -nr "$LEADERBOARD" | head -n 1 | awk '{print $1}')

  clear
  draw_border
  echo "GAME OVER"
  echo
  echo "Final Score : $SCORE / $TOTAL"
  echo "Final WPM   : $FINAL_WPM"
  echo "Best WPM    : $BEST"
  echo
  echo "Accuracy:"
  echo " Short  Words : ${SHORT_ACC}%"
  echo " Medium Words : ${MEDIUM_ACC}%"
  echo " Long   Words : ${LONG_ACC}%"
  draw_border
  exit 0
}

trap exit_game SIGINT SIGTERM

# ==================================================
# MAIN
# ==================================================
welcome
sleep 2
select_mode
select_category
play_game