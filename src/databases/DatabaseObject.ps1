


. "$($PSScriptRoot)\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\ConnectionDB.ps1"
. "$($PSScriptRoot)\..\shared\Functions.ps1"

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
            $ErrorMessage = "Class $type must be inherited."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }
    }

    static [void]SetDatabase([type]$TargetType, $Database) {
        $TargetType::Database = $Database
    }

    static [System.Collections.ArrayList]FindBySql([type]$TargetType, $Sql) {

        $Result = $TargetType::Database.Query($Sql, $false)
        if (-not $Result) {
            $ErrorMessage = "Database query failed."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }

        # Results into objects
        $ObjectArray = [System.Collections.ArrayList]@()
        $NewInstance = $null

        for ($i = 0; $i -lt $Result.Count; $i++) {
            $NewInstance = $TargetType::Instantiate($TargetType, $Result[$i])[0]
            $ObjectArray.Add( $NewInstance )
        }

        # My alternative to mysqli_result::free() method.
        Clear-Variable -Name "Result"

        return $ObjectArray

    }

    static [System.Collections.ArrayList]FindAll([type]$TargetType){
        $Sql = "SELECT * FROM $($TargetType::TableName)"
        return $TargetType::FindBySql($TargetType, $Sql)
    }

    static [int]CountAll([type]$TargetType) {
        $Sql = "SELECT COUNT(*) FROM $($TargetType::TableName)"
        $ResultSet = $TargetType::Database.Query($Sql, $null)
        $Row = $ResultSet[0]
        $Value = $Row["COUNT(*)"]

        return $Value
    }

    hidden static [System.Collections.ArrayList]Instantiate([type]$TargetType, $Record) {
        <#
        .SYNOPSIS
            Creates an instance of itself.

        .DESCRIPTION
            The properties will be automatically assigned.

        .PARAMETER [type]$TargetType
            The class itself.

        .PARAMETER [System.Collections.Hashtable]$Record
            A hashtable representing a row in the result set table.

        .OUTPUTS
            An instance of the class

        .LINK
            # Check if Object has Property in PowerShell
            https://java2blog.com/check-if-object-has-property-powershell/
        #>

        $ObjectArray = [System.Collections.ArrayList]@()
        $Object = $TargetType::new($null)

        foreach($Key in $Record.Keys) {
            if (Get-Member -inputobject $Object -name $Key -Membertype Properties) {
                $Object.$Key = $Record[$Key]
            }
        }

        $ObjectArray.Add($Object)
        return $ObjectArray
    }

}

class Admins : DatabaseObject {
    hidden static $TableName = "admins"
    hidden static $DBColumns = [System.Collections.ArrayList]@(
        'id',
        'first_name',
        'last_name',
        'email',
        'username',
        'hashed_password'
    )

    $id
    $first_name
    $last_name
    $email
    $username
    $hashed_password
    $password
    $confirm_password
    $password_required = $True

    Admins($Properties) {

        if ($null -ne $Properties) {
            $this.first_name       = $Properties["first_name"]
            $this.last_name        = $Properties["last_name"]
            $this.email            = $Properties["email"]
            $this.username         = $Properties["username"]
            $this.password         = $Properties["password"]
            $this.confirm_password = $Properties["confirm_password"]
        }
        else {
            $this.first_name       = ""
            $this.last_name        = ""
            $this.email            = ""
            $this.username         = ""
            $this.password         = ""
            $this.confirm_password = ""
        }

    }

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
