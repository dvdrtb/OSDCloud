<#
.SYNOPSIS
    OSD-Cloud Win 11 24H2 Automation

.DESCRIPTION
    
.NOTES
    Author      : David Rechtenbach
    Version     : 1.0
    Date        : 17.03.2025
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

Write-Host -ForegroundColor Green "Updating OSD Powershell Module"
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
    Firmware = $False
}
Start-OSDCloud @Params

################################################################ 
# PostOS Generate UnattendXml
################################################################
$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>Start PS session</Description>
                    <Path>powershell.exe -NoL -ExecutionPolicy Bypass</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <InputLocale>de-DE</InputLocale>
            <SystemLocale>de-DE</SystemLocale>
            <UILanguage>de-DE</UILanguage>
            <UserLocale>de-DE</UserLocale>
        </component>
    </settings>
</unattend>
'@ 
# Get-OSDGather -Property IsWinPE
Block-WinOS

if (-NOT (Test-Path 'C:\Windows\Panther')) {
    New-Item -Path 'C:\Windows\Panther'-ItemType Directory -Force -ErrorAction Stop | Out-Null
}

$Panther = 'C:\Windows\Panther'
$UnattendPath = "$Panther\Unattend.xml"
$UnattendXml | Out-File -FilePath $UnattendPath -Encoding utf8 -Width 2000 -Force

################################################################ 
# Restart PC
################################################################
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
