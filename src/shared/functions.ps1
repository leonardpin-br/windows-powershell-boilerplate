# REFERENCES:
# How to get the caller Function Name in the called function in PS?
# https://social.technet.microsoft.com/Forums/Azure/en-US/9b8f3677-8416-4685-978a-7daef61d7c52/how-to-get-the-caller-function-name-in-the-called-function-in-ps?forum=winserverpowershell
# PowerShell to remove text from a string
# https://stackoverflow.com/a/19169526/3768670

function PrintErrorMessage {

    param ($ErrorMessage)

    # $caller_function = (Get-PSCallStack)[1].Command
    $caller_function = (Get-PSCallStack)[1]
    $caller_function = $caller_function -replace "at " -replace ",.*"

    Write-Host "`n`n================================================================================================`n"
    Write-Host -ForegroundColor Red "Error:"
    Write-Host "$($caller_function)(): $($ErrorMessage)"
    Write-Host ""
    Write-Host "================================================================================================`n`n"

}