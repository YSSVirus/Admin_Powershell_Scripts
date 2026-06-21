# Admin PowerShell Scripts

A collection of PowerShell scripts for system administration, software deployments, user management, Windows maintenance, and general IT automation.

Most of these scripts were created or inspired due to a seen need at working at an MSP or talking with users. The goal is to spread the knowledge and hopefuly it will help someone or some people along the way,

## Repository Layout

📦 [Applications](https://github.com/YSSVirus/Admin_Powershell_Scripts/tree/main/Applications)

Silent installers, uninstallers, and software deployment scripts intended to simplify application management and standardize deployments.

🖥️ [BIOS](https://github.com/YSSVirus/Admin_Powershell_Scripts/tree/main/BIOS)

Utilities for collecting, displaying, and documenting BIOS and hardware information useful for inventory, troubleshooting, and auditing.

⚙️ [Configuration](https://github.com/YSSVirus/Admin_Powershell_Scripts/tree/main/Configuration)

Scripts designed to configure Windows settings, enforce preferences, and make common system changes easier to manage.

👤 [User Management](https://github.com/YSSVirus/Admin_Powershell_Scripts/tree/main/User%20managment)

Tools for managing local and Active Directory accounts, including password resets, account maintenance, and other administrative tasks.

🔄 [Windows Updates](https://github.com/YSSVirus/Admin_Powershell_Scripts/tree/main/Windows%20Updates)

Scripts focused on detecting, installing, and automating Windows updates while providing better visibility into the update process.

🧩 [Templates](https://github.com/YSSVirus/Admin_Powershell_Scripts/tree/main/Templates)

Reusable functions, project structures, and script templates intended to accelerate development and encourage consistency across scripts.

## Quick Examples

```powershell
.\BIOS-Viewer.ps1

.\Install-Zoom.ps1

.\Control-usbStorage.ps1 -Disable
```

## Recommendations

* Windows 10/11
* PowerShell 5.1+
* Some scripts may require administrative privileges
* Where practical, compatibility with older PowerShell versions is considered, though it cannot always be guaranteed

## Contributing

Suggestions, pull requests, and script ideas are always welcome. If you have a utility you've found useful in your own environment, feel free to share it.
