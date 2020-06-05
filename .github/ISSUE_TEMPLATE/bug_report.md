---
name: Bug report
about: Create a report to help us improve
title: '[Bug] '
labels: ''
assignees: ''

---
<!-- 
Please read this first!

- ISSUES THAT DO NOT FOLLOW THE FORMAT CAN BE AUTOMATICALLY CLOSED. 
- Please search past issues before posting 
- Please consult the documentation first, it includes valuable steps for troubleshooting. https://docs.swizzin.ltd/guides/troubleshooting 
- If your issue is about the swizzin front PANEL, please post these issues into the correct repository here https://github.com/liaralabs/swizzin_dashboard/issues

Thanks for your cooperation! Following this will help us help you better :)
-->
## Did you read the disclaimer?
<!-- Put an x between the brackets -->
- [] Yes I did

## Bug description
A clear and concise description of what the bug is.

## Reproduction steps
Steps to reproduce the behavior:
1. Install package '...'
2. Go to '....'
3. Error '...'

## Installed applications through swizzin
e.g. Nginx, ffmpeg, panel

## Expected behavior
A clear and concise description of what you expected to happen.

## Server Info
**(please complete the following information):**
 - OS: [e.g. Debian 10, Ubuntu 20.04]
 - Image Source: [e.g. "Vanilla download" or "Install script from my provider (specify which)"]

## Is Swizzin up to date?
- Please run `box update`, and report whether that was successful. Please try to reproduce your issue again.

- Please mention the commit hash you are seeing
  - [e.g. `HEAD is now at `**`d4d151b`** `...`]

## Additional context
Add any other context about the problem here. Logs, terminal output, etc.

Good sources for log output could be the following: (only if they have relevant information)
- `cat /root/logs/install.log`
- `cat /root/logs/swizzin.log`
- `cat /var/logs/nginx/error.log`
- `systemctl status <app>@<(user)>`
- `journalctl -xe`

**Please paste your code into code blocks using the codeblock format like so**

 ``` 
 ... logs ... 
 ```

