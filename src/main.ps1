# References:
# dot sourcing with relative paths in powershell
# https://stackoverflow.com/a/65300899/3768670
# Code Layout and Formatting
# https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/code-layout-and-formatting#Capitalization-Conventions

# Importing a script:
. "$($PSScriptRoot)\databases\database_functions.ps1"
. "$($PSScriptRoot)\databases\connection_db.ps1"
. "$($PSScriptRoot)\shared\validation_functions.ps1"

# Main function.
function Main {
    <#
        .SYNOPSIS
            The main function of this example app.
    #>

    # Starts clearing the terminal.
    Clear-Host

    # $connection = Connect-MySQL

    # Disconnect-MySQL -Connection $connection
}

Main