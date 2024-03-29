# References:
# dot sourcing with relative paths in powershell
# https://stackoverflow.com/a/65300899/3768670
# Code Layout and Formatting
# https://poshcode.gitbook.io/powershell-practice-and-style/style-guide/code-layout-and-formatting#Capitalization-Conventions

# Importing a script:
. "$($PSScriptRoot)\shared\Functions.ps1"
. "$($PSScriptRoot)\..\config\Initialize.ps1"
# . "$($PSScriptRoot)\..\src\databases\ConnectionDB.ps1"
. "$($PSScriptRoot)\..\src\databases\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\..\src\appclasses\Admin.ps1"

# Main function.
function Main {
    <#
        .SYNOPSIS
            The main function of this example app.
    #>

    # Starts clearing the terminal.
    Clear-Host

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
        # $ConnectionDb = [ConnectionDB]::new()
        # $ConnectionDb = [ConnectionDB]::new("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll", "localhost", "webuser", "secretpassword", "chain_gang")
        # $Sql = "INSERT INTO admins (first_name, last_name, email, username, hashed_password) "
        # $Sql += "VALUES ('Leonardo', 'Pinheiro', 'info@leonardopinheiro.net', 'leo', 'zzzz')"

        # $ResultSet = $ConnectionDb.Query($Sql, $True)

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

    # $Sql = "SELECT * FROM admins"
    # $Result = [Admins]::FindBySql([Admins], $Sql)
    # Write-Host "After Result"

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

    # $Result = [Admins]::FindAll([Admins])
    # Write-Host "After Result"

    # $Result = [Admins]::CountAll([Admins])
    # Write-Host "The row count is $($Result)."

    # $Admin = [Admins]::FindById([Admins], 1)[0]

    # Write-Host "ID: $($Admin.id)"
    # Write-Host "First name: $($Admin.first_name)"
    # Write-Host "Last name: $($Admin.last_name)"
    # Write-Host "Email: $($Admin.email)"
    # Write-Host "Username: $($Admin.username)"
    # Write-Host "Hashed password: $($Admin.hashed_password)"
    # Write-Host "-------------------------------------------`n"

    # DELETE
    # --------------------------------------------------------------------------
    # $Admin = [Admins]::FindById([Admins], 27)[0]
    # $Result = $Admin.Delete()
    # if ($Result) {
    #     PrintSuccessMessage -SuccessMessage "The Admin '$($Admin.first_name)' was successfully deleted."
    # }

    # ATTRIBUTES TEST
    # --------------------------------------------------------------------------
    # $Admin = [Admins]::FindById([Admins], 12)[0]
    # $Result = $Admin.Attributes([Admins])
    # Write-Host "The result is '$($Result)'."

    # SANITIZEDATTRIBUTES TEST
    # --------------------------------------------------------------------------
    # $Admin = [Admins]::FindById([Admins], 12)[0]
    # $Result = $Admin.SanitizedAttributes([Admins])
    # Write-Host "The result is '$($Result)'."

    # MERGEATTRIBUTES TEST
    # --------------------------------------------------------------------------
    # $Admin = [Admins]::FindById([Admins], 12)[0]
    # if($Admin) {
    #     [System.Collections.Hashtable]$Kwargs = @{
    #         # "id" = $null;
    #         "id" = $Admin.id;
    #         "first_name" = $Admin.first_name;
    #         "last_name" = $Admin.last_name;
    #         "email" = $Admin.email;
    #         "username" = $Admin.username;
    #         "hashed_password" = $Admin.hashed_password;
    #     }

    #     $Admin.MergeAttributes($Kwargs)
    #     $Result = $Admin.Update()
    #     if($Result) {
    #         PrintSuccessMessage -SuccessMessage "The admin was updated."
    #     }
    #     else {
    #         PrintErrorMessage -ErrorMessage "There was an error in the update process."
    #     }
    # }
    # else {
    #     PrintErrorMessage -ErrorMessage "The ID was not found."
    # }

    # CREATE TEST
    # --------------------------------------------------------------------------
    # [System.Collections.Hashtable]$Properties = @{
    #     first_name = "Leonardo";
    #     last_name = "Pinheiro";
    #     email = "info@leonardopinheiro.net";
    #     username = "leo";
    #     password = "secretpassword";
    #     confirm_password = "secretpassword";
    # }

    # # Creates an object in memory.
    # $Admin = [Admins]::new($Properties)
    # $Admin.hashed_password = "zzzzzzzzzz"

    # # Saves the object in memory in the database.
    # $Result = $Admin.Save()
    # if (-not $Result) {
    #     PrintErrorMessage -ErrorMessage "The first error in the validation was: '$($Admin.Errors[0])'. There may be more."
    # }
    # else {
    #     PrintSuccessMessage -SuccessMessage "Object saved."
    # }

    # FINDBYID TEST
    # --------------------------------------------------------------------------
    # $Admin = [Admins]::FindById([Admins], 1000)[0]
    # if ($Admin) {
    #     PrintSuccessMessage -SuccessMessage "The admin '$($Admin.first_name)' was found."
    # }
    # else {
    #     PrintErrorMessage -ErrorMessage "The ID was not found."
    # }

    # UPDATE TEST
    # --------------------------------------------------------------------------
    $Admin = [Admins]::FindById([Admins], 28)[0]
    if ($Admin) {
        $Admin.first_name = "Leonardo";
        $Admin.last_name = "Pinheiro";
        $Admin.email = "info@leonardopinheiro.net";
        $Admin.username = "leon";
        $Admin.password = "secretpassword";
        $Admin.confirm_password = "secretpassword";

        # Saves the object in memory in the database.
        [bool]$Result = $Admin.Save()
        if (-not $Result) {
            PrintErrorMessage -ErrorMessage "The first error in the validation was: '$($Admin.Errors[0])'. There may be more."
        }
        else {
            PrintSuccessMessage -SuccessMessage "Object saved."
        }
    }
    else {
        PrintErrorMessage -ErrorMessage "The ID was not found."
    }


}

Main