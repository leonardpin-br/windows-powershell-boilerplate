# References:
# dot sourcing with relative paths in powershell
# https://stackoverflow.com/a/65300899/3768670
# Code Layout and Formatting
# https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/code-layout-and-formatting#Capitalization-Conventions

# Importing a script:
. "$($PSScriptRoot)\..\config\Initialize.ps1"
. "$($PSScriptRoot)\..\src\databases\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\..\src\databases\DatabaseObject.ps1"

# Main function.
function Main {
    <#
        .SYNOPSIS
            The main function of this example app.
    #>

    # Starts clearing the terminal.
    # Clear-Host

    # READ
    # ==========================================================================
    # $Sql = "SELECT * FROM admins"
    # $ResultSet = $database.Query($Sql, $null)

    # for ($i = 0; $i -lt $ResultSet.Count; $i++) {

    #     $row = $ResultSet[$i]

    #     Write-Host "ID: $($row["id"])"
    #     Write-Host "First name: $($row["first_name"])"
    #     Write-Host "Last name: $($row["last_name"])"
    #     Write-Host "Email: $($row["email"])"
    #     Write-Host "Username: $($row["username"])"
    #     Write-Host "Hashed password: $($row["hashed_password"])"
    #     Write-Host "-------------------------------------------`n"

    # }

#     # CREATE
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "INSERT INTO admins (first_name, last_name, email, username, hashed_password) "
#     $Sql += "VALUES ('Leonardo', 'Pinheiro', 'info@leonardopinheiro.net', 'leo', 'zzzz')"

#     $ResultSet = $ConnectionDb.Query($Sql, $True)

#     # UPDATE
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "UPDATE admins "
#     $Sql += "SET username = 'leo' "
#     $Sql += "WHERE id = 22"

#     $ResultSet = $ConnectionDb.Query($Sql, $True)
#     if ($ConnectionDb.AffectedRows -eq 0) {
#         PrintErrorMessage -ErrorMessage "The ID was not found."
#     }

#     # DELETE
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "DELETE FROM admins "
#     $Sql += "WHERE id = 22 "
#     $Sql += "LIMIT 1"

#     $ResultSet = $ConnectionDb.Query($Sql, $True)
#     if ($ConnectionDb.AffectedRows -eq 0) {
#         PrintErrorMessage -ErrorMessage "The ID was not found."
#     }

    # # Expected error:
    # $Test = [DatabaseObject]::new()

    $Sql = "SELECT * FROM admins"
    $Result = [Admins]::FindBySql([Admins], $Sql)
    Write-Host "After Result"

    # $Properties = @{
    #     first_name = "Leonardo";
    #     last_name = "Pinheiro";
    #     email = "info@leonardopinheiro.net";
    #     username = "leonardo";
    #     password = "password";
    #     confirm_password = "password";
    # }
    # $Admin = [Admins]::new($Properties)
    # Write-Host "After Result"
}

Main