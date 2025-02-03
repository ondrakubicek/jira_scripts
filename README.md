# jira_scripts
automated jira scripts

## Mandatory env
JIRA_EMAIL="name@domain.com"
JIRA_TOKEN=""
JIRA_DOMAIN="domain.atlassian.net"

## Optional env
TICKET_DEFAULT="CEREMONY-11"

## Jira Token
- go to https://id.atlassian.com/manage-profile/security/api-tokens
- generate token

## How to 
run `./log_jira.sh --ticket FWBA-11 --time-spent 15m --log-time=9:45 --day-to 2025-01-15 --day-from 2025-01-03` 


# JIRA Log Automation Script

This script automatically logs work in JIRA for a specified ticket and time range. It supports logging for multiple days while skipping weekends. Notifications are displayed on macOS upon successful execution.

## Features
- Logs work to a specified JIRA ticket
- Supports logging for a single day or a date range
- Automatically skips weekends
- Uses environment variables for authentication
- Displays macOS notifications upon success

## Prerequisites
- macOS with `bash` and `curl`
- JIRA API access with an API token
- `.env` file containing:
  ```env
  JIRA_EMAIL=your_email@example.com
  JIRA_TOKEN=your_api_token
  JIRA_DOMAIN=your_jira_instance.atlassian.net
  ```

## Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/jira-log-automation.git
   cd jira-log-automation
   ```
2. Create a `.env` file and add your JIRA credentials.
3. Ensure the script has execute permissions:
   ```bash
   chmod +x log_jira.sh
   ```
## Jira Token
- Generate token at https://id.atlassian.com/manage-profile/security/api-tokens

## Usage

### Log work for today
```bash
./log_jira.sh
```
This logs **0.25h at 09:45 AM** for **today** on ticket `FWBA-11`.

### Log work for a specific day
```bash
./log_jira.sh --day-from 2025-02-06
```
Logs **0.25h at 09:45 AM** for **February 6, 2025**.

### Log work with custom time and duration
```bash
./log_jira.sh --ticket FWBA-11 --day-from 2025-02-06 --time-spent 15m --log-time=10:30
```
Logs **0.5h at 10:30 AM** for **February 6, 2025**.

### Log work for a date range
```bash
./log_jira.sh --ticket FWBA-11 --time-spent 15m --log-time=9:45 --day-from 2025-01-05 --day-to 2025-01-10
```
Logs **0.25h at 09:45 AM** for **all weekdays between January 5-10, 2025**.

## Automating with macOS Automator
1. Open **Automator** and create a new **Application**.
2. Add a **Run Shell Script** action.
3. Set Shell to `/bin/bash` and paste:
   ```bash
   /path/to/log_jira.sh
   ```
4. Save the application and schedule it in **Calendar** or **launchd**.

## Troubleshooting
- Ensure `.env` is correctly set up and contains valid credentials.
- Check execution permissions: `chmod +x log_jira.sh`
- Run manually and check output/logs.

