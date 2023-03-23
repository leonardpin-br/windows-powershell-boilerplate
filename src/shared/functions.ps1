function PrintErrorMessage {

    param ($ErrorMessage)

    $caller_function = (Get-PSCallStack)[1].Command

    Write-Host "`n`n================================================================================================`n"
    Write-Host -ForegroundColor Red "Error:"
    Write-Host "$($caller_function)(): $($ErrorMessage)"
    Write-Host ""
    Write-Host "================================================================================================`n`n"

}