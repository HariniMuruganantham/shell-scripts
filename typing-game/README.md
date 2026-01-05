# Shell Typing Game

A terminal-based **Typing Game** developed using **Bash Shell Scripting** on Linux.  
This project helps users improve typing speed and accuracy using an interactive,
menu-driven command-line interface.

---

## 📖 Introduction

The Shell Typing Game demonstrates how Bash scripting can be used to build
interactive terminal applications.  
The game displays random words on the screen, and the user must type them correctly
within a limited time based on the selected difficulty level.

This project focuses on **shell scripting fundamentals**, **user input handling**,
**time-based logic**, and **signal handling**.

---

## 🎯 Objectives

- To understand and apply Bash shell scripting concepts
- To build a menu-driven terminal application
- To handle timed user input and calculate accuracy
- To implement graceful program termination using signals
- To use Linux utilities for random data generation

---

## ✨ Features

- Welcome screen with colors and borders
- Difficulty selection:
  - Easy
  - Medium
  - Hard
- Word typing based on difficulty level
- Random word selection
- Time-limited typing using `read -t`
- Accuracy calculation
- Graceful exit using signal handling (`Ctrl + C`)

---

## 📚 Word Library (Local Setup)

This project uses **Linux dictionary words** for typing practice.

> **Note:**  
> Dictionary word files are **generated locally** and are **not pushed to GitHub**.

### Install Dictionary (if not available)

```bash
sudo apt install wamerican
```
Generate Word Files Locally

Run the following commands inside the project folder:

```
mkdir -p words

awk 'length($0)>=3 && length($0)<=4 {print tolower($0)}' /usr/share/dict/words > words/short.txt
awk 'length($0)>=5 && length($0)<=7 {print tolower($0)}' /usr/share/dict/words > words/medium.txt
awk 'length($0)>=8 {print tolower($0)}' /usr/share/dict/words > words/long.txt
```

These files are used by the script at runtime.

## 🗂 Leaderboard File

The leaderboard file is created automatically while playing the game

It stores user-specific scores

It is not committed to GitHub, as it is runtime-generated data

## 🛠 Technologies Used

Bash Shell Script

Linux Terminal (Ubuntu / WSL)

Git & GitHub

## 📂 Project Structure (GitHub)
```
typing-game/
├── typing_game.sh
└── README.md
```
## ▶ How to Run the Project

Navigate to the project directory:
```
cd typing-game
```

Give execute permission:
```
chmod +x typing_game.sh
```
Run the game:
```
./typing_game.sh
```
Exit anytime using:
```
Ctrl + C
```
## 🧠 Learning Outcomes

After completing this project, you will be able to:

Write modular and readable Bash scripts

Use ANSI escape codes for colored terminal output

Implement menu-driven programs in shell scripting

Handle timed user input

Use Linux utilities such as shuf and awk

Handle system signals using trap

Use Git and GitHub for version control

## 👩‍💻 Author

Harini