# The location of this file should be:
# "C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
#
# References:
# Console Virtual Terminal Sequences
# https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
# about_Profiles
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3#add-a-customized-powershell-prompt


# Writes the username and the computer name.
function Prompt
{
    # Inserts a blank line.
    Write-Host ""

    $location = (Get-Location)

    $ESC = [char]27
    "$ESC[93m$env:USERNAME" + "@" + $env:COMPUTERNAME + " $ESC[95mPS " + "$ESC[92m$location" + "$ESC[97m > "
}