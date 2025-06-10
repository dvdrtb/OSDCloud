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
# Copy Import-Cert.ps1 and PFX to Target System
################################################################
Write-Host -ForegroundColor Cyan "Copying certificate and import script to C:\OSDCloud\Scripts..."

$source = "X:\OSDCloud\Config\Scripts"
$target = "C:\OSDCloud\Scripts"

if (-not (Test-Path $target)) {
    New-Item -ItemType Directory -Path $target -Force | Out-Null
}

Copy-Item "$source\Import-Cert.ps1" -Destination $target -Force
Copy-Item "$source\OSDCloudRegistration.pfx" -Destination $target -Force

Write-Host -ForegroundColor Green "Files copied successfully."

################################################################ 
# PostOS Generate UnattendXml
################################################################
# Define the unattend.xml content as a here-string
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Start Autopilot Import & Assignment Process</Description>
                    <Path>powershell.exe -ExecutionPolicy Bypass -File "C:\Windows\Setup\scripts\autopilot.ps1"</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
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