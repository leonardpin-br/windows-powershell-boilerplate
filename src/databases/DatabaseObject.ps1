


. "$($PSScriptRoot)\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\ConnectionDB.ps1"

class DatabaseObject {
    <#
    .SYNOPSIS
        Abstract superclass to be instantiated from all the others that access the database.
    #>

    # [ConnectionDB] object that will store the connection.
    hidden static $Database
    hidden static $TableName
    hidden static $Columns
    $Errors = [System.Collections.ArrayList]@()

    static [void]SetDatabase($Database) {
        [DatabaseObject]::Database = $Database
    }
}

class Admins : DatabaseObject {

}

# function Main {
#     Clear-Host

#     # $admin = [Admins]::new()
#     # Write-Host $admin.Name

#     $Database = [ConnectionDB]::new()
#     $database = [DatabaseObject]::SetDatabase($Database)
#     $SuperclassDatabase = [DatabaseObject]::Database
#     $SubclassDatabase = [Admins]::Database
#     Write-Host "Test"
# }

# Main
