function ChecksAdminPrivileges {
    <#
    .SYNOPSIS
        Checks if this script is being executed with elevated privileges.
    .DESCRIPTION
        Makes sure that this script is being used with elevated privileges.
    .OUTPUTS
        Bool: True if the script is being execeuted with administrative privileges.
        False otherwise.
    .LINK
        # In a PowerShell script, how can I check if I'm running with administrator privileges?
        https://serverfault.com/a/95464
    #>

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $Result = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $Result
}


function PrintErrorMessage {
    <#
    .SYNOPSIS
        Prints a formatted (and easy to read in the console) error message.

    .LINK
        # How to get the caller Function Name in the called function in PS?
        https://social.technet.microsoft.com/Forums/Azure/en-US/9b8f3677-8416-4685-978a-7daef61d7c52/how-to-get-the-caller-function-name-in-the-called-function-in-ps?forum=winserverpowershell

    .LINK
        # PowerShell to remove text from a string
        https://stackoverflow.com/a/19169526/3768670
    #>

    param (
        # The error message to be printed.
        [String]$ErrorMessage
    )

    # $CallerFunction = (Get-PSCallStack)[1].Command
    $CallerFunction = (Get-PSCallStack)[1]
    $CallerFunction = $CallerFunction -replace "at " -replace ",.*"

    Write-Host "`n`n================================================================================================`n"
    Write-Host -ForegroundColor Red "Error:"
    Write-Host "$($CallerFunction)(): $($ErrorMessage)"
    Write-Host ""
    Write-Host "================================================================================================`n`n"

}


function PrintSuccessMessage {
    <#
    .SYNOPSIS
        Prints a formatted (and easy to read in the console) success message.

    .LINK
        # How to get the caller Function Name in the called function in PS?
        https://social.technet.microsoft.com/Forums/Azure/en-US/9b8f3677-8416-4685-978a-7daef61d7c52/how-to-get-the-caller-function-name-in-the-called-function-in-ps?forum=winserverpowershell

    .LINK
        # PowerShell to remove text from a string
        https://stackoverflow.com/a/19169526/3768670
    #>

    param (
        # The success message to be printed.
        [String]$SuccessMessage
    )

    Write-Host "`n`n================================================================================================`n"
    Write-Host -ForegroundColor Green "Success:"
    Write-Host "$($SuccessMessage)"
    Write-Host ""
    Write-Host "================================================================================================`n`n"

}


function PrintMessage([switch]$Success, [switch]$Warning, [switch]$Failure, [String]$Message) {
    <#
    .SYNOPSIS
        Prints a formatted (and easy to read in the console) message.
    .PARAMETER [switch]$Success
        Marks the message as a success message.
    .PARAMETER [switch]$Warning
        Marks the message as a warning message.
    .PARAMETER [switch]$Failure
        Marks the message as an error message.
    .PARAMETER [String]$Message
        The message to be printed.
    .EXAMPLE
        $Message = "This is the message."
        PrintMessage -Failure -Message $Message
    .LINK
        # How to get the caller Function Name in the called function in PS?
        https://social.technet.microsoft.com/Forums/Azure/en-US/9b8f3677-8416-4685-978a-7daef61d7c52/how-to-get-the-caller-function-name-in-the-called-function-in-ps?forum=winserverpowershell
    #>

    Write-Host "`n`n================================================================================================`n"
    if ($Success) {
        Write-Host -ForegroundColor Green "Success:"
    } elseif ($Warning) {
        Write-Host -ForegroundColor Yellow "Warning:"
    } elseif ($Failure) {
        Write-Host -ForegroundColor Red "Error:"
    } else {
        Write-Host "Message:"
    }

    # Gets the caller function of this function.
    $CallerFunction = (Get-PSCallStack)[1]
    $CallerFunction = $CallerFunction -replace "at " -replace ",.*"

    Write-Host "$($CallerFunction)(): $($Message)"
    Write-Host ""
    Write-Host "================================================================================================`n`n"

}