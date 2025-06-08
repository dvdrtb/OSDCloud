<#
.SYNOPSIS
    OSD-Cloud Win 11 24H2 Automation. No AutopilotNo Hardwarehash Upload during specialize phase

.DESCRIPTION
    
.NOTES
    Author      : David Rechtenbach
    Version     : 1.0
    Date        : 07.06.2025
    Last Update : XX.XX.XXXX
    Changes     : 

.REQUIREMENTS
   To use this script you need a winpe image with osd cloud module

.LINK
    https://www.osdcloud.com/
#>

################################################################ 
# PreOS Update OSD Module
################################################################
if ((Get-MyComputerModel) -match 'Virtual' ) {
    Write-Host -ForegroundColor Green "Setting Resolution to 1600x"
    Set-DisRes 1600
}

#Write-Host -ForegroundColor Green "Updating OSD Powershell Module"
Install-Module OSD -Force

Write-Host -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force

################################################################ 
# OS Settings
################################################################
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "24H2"
    OSEdition = "Pro"
    OSLanguage = "de-de"
    OSLicense = "Retail"
    ZTI = $True
    Firmware = $True
}
Start-OSDCloud @Params

################################################################ 
# PostOS Generate UnattendXml No Autopilot
################################################################

# Define the unattend.xml content as a here-string
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>de-DE</InputLocale>
            <SystemLocale>de-DE</SystemLocale>
            <UILanguage>de-DE</UILanguage>
            <UserLocale>de-DE</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <TimeZone>W. Europe Standard Time</TimeZone>
        </component>
    </settings>
</unattend>
'@

# Ensure the Panther directory exists — required by Windows Setup
if (-not (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther' -ItemType Directory -Force | Out-Null
}

# Define the target path for Unattend.xml
$UnattendPath = 'C:\Windows\Panther\Unattend.xml'

# Write the unattend content to file in UTF-8 encoding
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

################################################################ 
# Restart PC
################################################################
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
