
# Shell Scripts Toolkit

This repository includes four Bash scripts designed for Linux system automation and monitoring tasks. Each script is interactive and user-friendly.

---

## 📦 1. `backup_script.sh`

Creates a compressed backup of a specified directory.

### Features:
- Prompts the user for the full path of the directory to back up.
- Validates that the directory exists and is readable.
- Creates a gzip-compressed `.tar.gz` file in `~/backups/`, named like:  
  `backup_<dir_name>_YYYYMMDD_HHMMSS.tar.gz`
- Retains only the last 7 backups; older ones are automatically deleted.
- Notifies the user about success or any errors.

---

## 📄 2. `log_monitor.sh`

Monitors log files for important entries.

### Features:
- Prompts the user for the full path of a system log file (e.g. `/var/log/syslog`).
- Searches for entries containing keywords: `error`, `warning`, `critical` (case-insensitive).
- Saves matching lines into a report file:  
  `~/important_<log_name>_<date>.log`
- If no matches are found, the report is not created.
- Automatically deletes report files older than 7 days.
- Displays the number of matches and a preview (first 5 lines).

---

## 🖥️ 3. `system_info.sh`

Displays system and hardware information in a formatted output.

### Features:
- Shows current date/time, hostname, user.
- Displays CPU/RAM usage and disk space.
- Lists:
  - OS name, kernel version, uptime
  - Number of installed packages
  - Desktop environment and window manager (if available)
  - Top 5 processes by CPU and RAM usage
- Uses color-coded output for clarity.

---

## 📂 4. `organize_by_extension.sh`

Organizes files in a specified directory based on file extension.

### Features:
- Accepts a directory as input.
- Validates the directory’s existence.
- Creates subfolders for each unique file extension.
- Moves files into corresponding subfolders (e.g. `.txt` → `txt/`).
- Files without extensions go into a `no_extension/` folder.
- Displays informative messages during the organization process.

---

## 💡 Usage

Each script is executable. Make sure to give execute permissions:

\`\`\`bash
chmod +x script_name.sh
\`\`\`

Then run:

\`\`\`bash
./script_name.sh
\`\`\`

For `organize_by_extension.sh`, provide the directory as an argument:

\`\`\`bash
./organize_by_extension.sh /path/to/your/folder
\`\`\`

---

## 📎 Requirements

- Bash shell (typically preinstalled on most Linux distros)
- Standard GNU utilities (`tar`, `find`, `grep`, `df`, `ps`, etc.)
