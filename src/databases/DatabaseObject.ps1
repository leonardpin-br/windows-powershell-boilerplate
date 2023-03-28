


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
        # $Type = $this.GetType()
        # if ($Type -eq [DatabaseObject]) {
        #     $ErrorMessage = "Class $type must be inherited."
        #     PrintErrorMessage -ErrorMessage $ErrorMessage
        #     throw $ErrorMessage
        # }
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
        $ObjectArray =[System.Collections.ArrayList]@()
        $NewInstance = $null

        for ($i = 0; $i -lt $Result.Count; $i++) {
            $NewInstance = $TargetType::Instantiate($TargetType, $Result[$i])[0]
            $ObjectArray.Add( $NewInstance )
        }

        # My alternative to mysqli_result::free() method.
        Clear-Variable -Name "Result"

        return $ObjectArray

    }

    hidden static [System.Collections.ArrayList]Instantiate([type]$TargetType, $Record) {
        $ObjectArray = [System.Collections.ArrayList]@()
        $Object = $TargetType::new()

        # foreach($Key in $Record.Keys) {
        #     if ( [bool]($Object.PSobject.Properties | Where-Object { $_.Name -eq "myPropertyNameToTest"}) ) {
        #         $Object | Add-Member -MemberType NoteProperty -Name $Key -Value $Record[$Key]
        #     }
        # }

        $ObjectArray.Add($Record)
        return $ObjectArray
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
