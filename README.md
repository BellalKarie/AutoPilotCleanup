AutoPilotCleanup
PowerShell script to remove Windows Autopilot and Intune device records using a list of serial numbers.

Requirements
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module WindowsAutoPilotIntune -Scope CurrentUser

Create a file named: serialNumbers.csv
Example:
- ABC1234
- DEF5678
- GHI9012
so on, so forth...

Place the file in the same directory as the script and run: ./AutoPilotCleanup.ps1

Features:
- Removes Windows Autopilot records
- Removes Intune-managed devices
- Processes multiple devices from a CSV file
- Generates a cleanup log
- Displays a final results summary

Example Output
==================================================
Serial Number: ABC1234
Device Name: Device01
==================================================
✓ Autopilot removed
✓ Intune removed
Log File
The script creates:

cleanup-results.log
containing successful removals, failures, and devices not found.

Disclaimer
Use at your own risk. Verify all serial numbers before performing bulk device removals.

Acknowledgements
Inspired by an existing Autopilot cleanup workflow and rebuilt using PowerShell 7 and Microsoft Graph.
