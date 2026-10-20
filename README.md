AutoPilotCleanup

PowerShell script to remove Windows Autopilot and Intune device records by serial number.

What this script is about

Removing devices from Windows Autopilot and Intune can be time-consuming when processing multiple devices.

This script automates the following tasks:

1. Remove the device from the Windows Autopilot device list.
2. Remove the device from the Intune managed device list.
3. Display detailed results for each serial number.
4. Generate a cleanup summary and log file.

Note: This script does NOT remove Entra ID / Azure AD device objects.

Disclaimer: Use of this script is at your own risk.

Step-by-Step

1. Create a CSV file with serial numbers.

Create a file named:

serialNumbers.csv

The file should contain one serial number per line with no header.

Example:

22K2SQ3
6N93SQ3
DS0K9K3
590H8D3

Store this file in the same folder as the script.

2. Install the required PowerShell modules.

Open PowerShell and run:

Install-Module Microsoft.Graph -Scope CurrentUser

Install-Module WindowsAutoPilotIntune -Scope CurrentUser

3. Execute the script.

Navigate to the folder containing the script and CSV file:

cd "/path/to/AutoPilotCleanup"

Run:

./AutoPilotCleanup.ps1

The script will prompt for Microsoft Graph authentication if required.

4. Monitor the results.

During execution the script displays the status of each serial number.

Example:

==================================================
Serial Number : 590H8D3
Device Name   : VAWS-590H8D3
==================================================
✓ Autopilot removed
✓ Intune removed

If a device cannot be found, the script will display:

==================================================
Serial Number : ABC12345
Device Name   : Not Found
==================================================
• Autopilot not found
• Intune not found

Final Results

At the end of execution a summary similar to the following is displayed:

==================================================
FINAL RESULTS
==================================================

Autopilot Removed : 2
Intune Removed    : 4
Not Found         : 27
Failed            : 1

Cleanup Complete.

Log File

A log file named:

cleanup-results.log

is created in the same folder as the script.

The log contains:

- Successful Autopilot removals
- Successful Intune removals
- Failed removals
- Devices not found

Version History

v2.0

- Rewritten for PowerShell 7
- Compatible with Windows and macOS
- Uses Microsoft Graph authentication
- Removes legacy Connect-MSGraph dependency
- Supports bulk processing using serialNumbers.csv
- Removes Windows Autopilot records
- Removes Intune managed device records
- Adds detailed per-device output
- Adds final cleanup summary
- Adds logging support

Acknowledgements

This project was inspired by an existing Autopilot cleanup workflow used within our Desktop Engineering team. The script was rebuilt using PowerShell 7 and Microsoft Graph while adding Intune cleanup, improved reporting, and cross-platform support.