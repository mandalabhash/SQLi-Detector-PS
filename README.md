# IIS SQL Injection Monitor

![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Security](https://img.shields.io/badge/Security-Expert-blue)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A real-time monitoring solution for detecting SQL injection attempts in IIS logs with desktop alerts and CSV logging.

## Features

- 🚨 **Real-time monitoring** of IIS log files
- 🔍 **Advanced pattern detection** for 15+ SQLi techniques
- 📊 **CSV logging** with timestamped alerts
- 🖥️ **Desktop notifications** via BurntToast
- 🎯 **Precise IP detection** (handles both IPv4 and IPv6)
- 📅 **Automatic log file rotation** based on UTC dates
- 🛡️ **Payload sanitization** for safe logging

## Installation

### Prerequisites
- Windows Server with IIS
- PowerShell 5.1 or later
- Administrative privileges

### Setup
1. Clone the repository:
   ```powershell
   git clone https://github.com/yourusername/iis-sqli-monitor.git
   cd iis-sqli-monitor
   ```

2. Install required module:
   ```powershell
   Install-Module BurntToast -Force -AllowClobber
   ```

## Usage

```powershell
.\detect.ps1 [-LogDirectory <path>]
```

### Parameters
| Parameter      | Default Value                          | Description                          |
|----------------|----------------------------------------|--------------------------------------|
| `-LogDirectory` | `C:\inetpub\logs\LogFiles\W3SVC2` | Path to IIS log files directory |

### Example
```powershell
# Monitor default IIS log location
.\detect.ps1

# Monitor custom log directory
.\detect.ps1 -LogDirectory "D:\iis_logs\W3SVC1"
```

## CSV Output Format
Alerts are logged to `sqli_alerts.csv` with the following columns:

| Column       | Format              | Example                    |
|--------------|---------------------|----------------------------|
| Date         | yyyy-MM-dd          | 2025-03-24                 |
| Time         | HH:mm:ss            | 14:35:12                   |
| IP Address   | IPv4/IPv6           | 192.168.1.100 or ::1       |
| Payload      | URL-decoded string  | `user=admin' OR 1=1--`     |

![pic-3](https://github.com/user-attachments/assets/2b214b23-9c8b-4ac3-9a75-a3ec2ba495f5)

## Detection Patterns
The script detects:
- Basic SQLi patterns (`'`, `--`, `#`)
- UNION-based attacks
- Boolean-based attacks (`OR 1=1`)
- Time-based delays (`WAITFOR DELAY`)
- Stored procedure execution
- Hex/URL encoded attacks
- And [12+ other techniques](https://owasp.org/www-community/attacks/SQL_Injection)

## Sample Alert
![pic-1](https://github.com/user-attachments/assets/ca4be9c9-2bbb-47fd-b971-e28b1a082f5e)
![pic-2 (Phone)](https://github.com/user-attachments/assets/7b0b1a43-e933-4587-83b0-8c0e1405bb35)



## Technical Details

### Log File Handling
- Automatically detects current UTC log file (`u_exYYMMDD.log`)
- Falls back to most recent log if current not found
- Processes new entries in real-time using `-Wait -Tail 0`

### IP Detection
Uses regex pattern:
```regex
(?<=^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s)(?<ClientIP>\S+).*?\s(?<SourceIP>\S+)(?=\s+Mozilla)
```

### Performance
- Processes ~5000 log entries/second
- Memory efficient (stream-based processing)
- Low CPU overhead (checks every 2 seconds)

## License
MIT License - See [LICENSE](LICENSE) for details.

---

**Contributions welcome!** Please open an issue or PR for any improvements to the detection patterns or functionality.
