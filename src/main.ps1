# References:
# dot sourcing with relative paths in powershell
# https://stackoverflow.com/a/65300899/3768670

# Importing a script:
. "$($PSScriptRoot)\databases\database_functions.ps1"
. "$($PSScriptRoot)\databases\connection_db.ps1"
. "$($PSScriptRoot)\shared\validation_functions.ps1"

# Main function.
function Main {

    # Starts clearing the terminal.
    Clear-Host

    # $connection = Connect-MySQL

    # Disconnect-MySQL -Connection $connection
}

Main