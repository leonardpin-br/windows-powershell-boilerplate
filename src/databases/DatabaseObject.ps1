


. "$($PSScriptRoot)\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\ConnectionDB.ps1"

class DatabaseObject {
    <#
    .SYNOPSIS
        Abstract superclass to be instantiated from all the others that access the database.

    .LINK
        # Powershell v5 Classes & Concepts
        https://xainey.github.io/2016/powershell-classes-and-concepts/#abstract-classes

    .LINK
        # How to reference the class and static properties dynamically from static methods in PowerShell?
        https://stackoverflow.com/a/75861705/3768670
    #>

    # [ConnectionDB] object that will store the connection.
    hidden static $Database
    hidden static $TableName
    hidden static $Columns
    $Errors = [System.Collections.ArrayList]@()

    # Makes this class abstract.
    DatabaseObject() {
        $Type = $this.GetType()
        if ($Type -eq [DatabaseObject]) {
            throw("Class $type must be inherited.")
        }
    }

    static [void]SetDatabase([type]$TargetType, $Database) {
        $TargetType::Database = $Database
    }

    hidden static [psobject]Instantiate([type]$TargetType, $Record) {
        $Object = $TargetType::new()
        return $Object
    }
}

class Admins : DatabaseObject {
    hidden static $TableName = "admins"

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
