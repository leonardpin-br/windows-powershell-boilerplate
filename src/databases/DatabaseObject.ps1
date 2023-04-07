<#
.SYNOPSIS
    Abstract superclass to be inherited from all the others that access the database.
.DESCRIPTION
    It is important to remember that, in PowerShell, static methods need to
    receive, as argument, the type.
.EXAMPLE
    class Admins : DatabaseObject {}
.LINK
    # How to Create Descriptive PowerShell Comments
    https://adamtheautomator.com/powershell-comment/

    # Powershell v5 Classes & Concepts
    https://xainey.github.io/2016/powershell-classes-and-concepts/#abstract-classes

    # How to reference the class and static properties dynamically from static methods in PowerShell?
    https://stackoverflow.com/a/75861705/3768670
#>

. "$($PSScriptRoot)\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\ConnectionDB.ps1"
. "$($PSScriptRoot)\..\shared\Functions.ps1"
. "$($PSScriptRoot)\..\shared\ValidationFunctions.ps1"

class DatabaseObject {

    # [ConnectionDB] object that will store the connection.
    hidden static $Database
    hidden static [string]$TableName = ""
    hidden static [System.Collections.ArrayList]$DbColumns = @()
    [System.Collections.ArrayList]$Errors = @()

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
        <#
        .SYNOPSIS
            Sets the static database property to be used in the connection
            with the database server (MySQL).
        .PARAMETER [type]$TargetType
            The class itself.
        .PARAMETER [ConnectionDB]$Database
            An instance of ConnectionDB returned by the Connect-MySQL
            (src\databases\DatabaseFunctions.ps1) function inside the
            <ProjectRoot>\config\Initialize.ps1 file.
        .EXAMPLE
            $database = Connect-MySQL -MySqlData $MySqlData -Server $Server -User $User -Password $Password -Database $Database
            [DatabaseObject]::SetDatabase([DatabaseObject], $Database)
        #>

        $TargetType::Database = $Database
    }

    static [System.Collections.ArrayList]FindBySql([type]$TargetType, [string]$Sql) {
        <#
        .SYNOPSIS
            Sends the SQL query to the database and returns an ArrayList of objects.
        .PARAMETER [type]$TargetType
            The class itself.
        .PARAMETER [string]$Sql
            The SQL string to be executed.
        .OUTPUTS
            ArrayList containing objects from the query result.
        .EXAMPLE
            $Sql = "SELECT * FROM $($TargetType::TableName)"
            return $TargetType::FindBySql($TargetType, $Sql)
        .NOTES
            Throws if the query does not bring back any result.
        #>

        [System.Collections.ArrayList]$ResultSet = $TargetType::Database.Query($Sql, $false)
        if ($ResultSet[0] -eq $false) {
            $ErrorMessage = "Database query failed."
            PrintErrorMessage -ErrorMessage $ErrorMessage

            # If the query was unsuccessful, returns the ArrayList with $false in it.
            return $ResultSet
        }

        # Results into objects
        $ObjectArray = [System.Collections.ArrayList]@()
        $NewInstance = $null

        for ($i = 0; $i -lt $ResultSet.Count; $i++) {
            $NewInstance = $TargetType::Instantiate($TargetType, $ResultSet[$i])[0]
            $ObjectArray.Add( $NewInstance )
        }

        # My alternative to mysqli_result::free() method.
        Clear-Variable -Name "Result"

        return $ObjectArray

    }

    static [System.Collections.ArrayList]FindAll([type]$TargetType){
        <#
        .SYNOPSIS
            Finds all records in the given database table.
        .PARAMETER [type]$TargetType
            The class itself.
        .OUTPUTS
            ArrayList containing objects.
        .EXAMPLE
            $Result = [Admins]::FindAll([Admins])
        #>

        $Sql = "SELECT * FROM $($TargetType::TableName)"
        return $TargetType::FindBySql($TargetType, $Sql)
    }

    static [int]CountAll([type]$TargetType) {
        <#
        .SYNOPSIS
            Returns the number of records in the given table.
        .PARAMETER [type]$TargetType
            The class itself.
        .OUTPUTS
            The integer number of rows in the given table.
        .EXAMPLE
            $Result = [Admins]::CountAll([Admins])
            Write-Host "The row count is $($Result)."
        #>

        $Sql = "SELECT COUNT(*) FROM $($TargetType::TableName)"
        $ResultSet = $TargetType::Database.Query($Sql, $false)
        $Row = $ResultSet[0]
        $Value = $Row["COUNT(*)"]

        return $Value
    }

    static [System.Collections.ArrayList]FindById([type]$TargetType, [int]$Id) {
        <#
        .SYNOPSIS
            Finds a record in the database, using the ID.
        .PARAMETER [type]$TargetType
            The class itself.
        .PARAMETER [int]$Id
            The ID number to be used in the query.
        .OUTPUTS
            An ArrayList containing one object corresponding to the database record.
        .EXAMPLE
            $Admin = [Admins]::FindById([Admins], 1000)[0]
            if ($Admin) {
                PrintSuccessMessage -SuccessMessage "The admin '$($Admin.first_name)' was found."
            }
            else {
                PrintErrorMessage -ErrorMessage "The ID was not found."
            }
        #>

        $Sql = "SELECT * FROM $($TargetType::TableName) "
        $Sql += "WHERE id='$($TargetType::Database.RealEscapeString($Id))'"
        $ObjectArray = $TargetType::FindBySql($TargetType, $Sql)

        # If the query was unsuccessful.
        if ($ObjectArray[0] -eq $false) {
            $ReturnValue = $null
            $ObjectArray[0] = $ReturnValue
        }

        return $ObjectArray

    }

    hidden static [System.Collections.ArrayList]Instantiate([type]$TargetType, $Record) {
        <#
        .SYNOPSIS
            Creates an instance of the class setting the properties with
            the values of the object passed as argument.
        .DESCRIPTION
            The properties will be automatically assigned.
        .PARAMETER [type]$TargetType
            The class itself.
        .PARAMETER [System.Collections.Hashtable]$Record
            A hashtable representing a row in the result set table.
        .OUTPUTS
            An ArrayList containing an instance of the subclass.
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

    hidden [System.Collections.ArrayList]Validate() {
        <#
        .SYNOPSIS
            Every class that extends this one (DatabaseObject) must implement this method.
        .OUTPUTS
            The errors string ArrayList.
        .NOTES
            Information or caveats about the function e.g. 'This function is not supported in Linux'
        #>

        $this.Errors = [System.Collections.ArrayList]@()

        return $this.Errors
    }

    hidden [bool]Create() {


        [bool]$Result = $false

        $this.Validate()
        if($this.Errors.count -ne 0) {
            # If there are any errors, returns the ($false) $Result.
            return $Result
        }

        $Attributes = $this.SanitizedAttributes()

        $Sql = "INSERT INTO $($this.GetType()::TableName) ("
        ForEach ($Key in $Attributes.Keys) {$Sql += "$($Key), "}
        $Sql = $Sql -replace ", $"
        $Sql += ") VALUES ('"
        ForEach ($Value in $Attributes.Values) {$Sql += "$($Value)', '"}
        $Sql = $Sql -replace ", '$"
        $Sql += ")"

        $Result = $this.GetType()::Database.Query($Sql, $true)[0]

        if ($Result) {
            $this.id = $this.GetType()::Database.InsertId
        }

        return $Result

    }

    hidden [bool]Update() {









        return [System.Collections.ArrayList]@()
    }

    [bool]Save() {
        # A new record will not have an ID yet.
        if(Is-Set -Variable $this.id) {
            return $this.Update()
        }
        else {
            return $this.Create()
        }
    }

    [void]MergeAttributes([System.Collections.Hashtable]$Arguments) {
        <#
        .SYNOPSIS
            Merges the attributes from the given Hashtable into the object in
            memory created from the FindById() method.
        .PARAMETER [System.Collections.Hashtable]$Arguments
            The Hashtable containing the new values to be merged and later updated.
        .EXAMPLE
            $Admin = [Admins]::FindById([Admins], 12)[0]
            if($Admin) {
                [System.Collections.Hashtable]$Kwargs = @{
                    # "id" = $null;
                    "id" = $Admin.id;
                    "first_name" = $Admin.first_name;
                    "last_name" = $Admin.last_name;
                    "email" = $Admin.email;
                    "username" = $Admin.username;
                    "hashed_password" = $Admin.hashed_password;
                }

                $Admin.MergeAttributes($Kwargs)
                $Result = $Admin.Update()
                if($Result) {
                    Write-Host "The admin was updated."
                }
                else {
                    Write-Host "There was an error in the update process."
                }
            }
            else {
                Write-Host "The ID was not found."
            }
        #>

        foreach($Key in $Arguments.Keys) {
            if (
                (Get-Member -inputobject $this -name $Key -Membertype Properties) -and
                -not (Is-Null($Arguments[$Key]))
                ) {
                $this.$Key = $Arguments[$Key]
            }
        }

    }

    [System.Collections.Hashtable]Attributes() {
        <#
        .SYNOPSIS
            Creates a Hashtable that has, as properties, the database columns
            (excluding ID) and the corresponding values from the instance object
            in memory.
        .PARAMETER [type]$TargetType
            The class itself.
        .OUTPUTS
            Hashtable containing the names of the columns and the
            corresponding values from the instance object in memory.
        #>

        [System.Collections.Hashtable]$Attributes = @{}

        foreach ($Column in $this.GetType()::DbColumns) {
            if($Column -eq 'id') {
                continue
            }
            $Attributes[$Column] = $this.$Column
        }

        return $Attributes

    }

    hidden [System.Collections.Hashtable]SanitizedAttributes() {
        <#
        .SYNOPSIS
            Sanitizes (escapes the values) of the object before sending to the database.
        .PARAMETER [type]$TargetType
            The class itself.
        .OUTPUTS
            Hashtable with the values escaped.
        #>

        [System.Collections.Hashtable]$Sanitized = @{}

        $this.Attributes().GetEnumerator() | ForEach-Object {
            $Sanitized[$_.Key] = $this.GetType()::Database.RealEscapeString($_.Value)
        }

        return $Sanitized

    }

    [bool]Delete() {
        <#
        .SYNOPSIS
            Deletes, in the database, the record that corresponds to the current
            instance object in memory.
        .DESCRIPTION
            After deleting, the instance object will still
            exist, even though the database record does not.
            This can be useful, as in the example below.
        .OUTPUTS
            An empty ArrayList.
        .EXAMPLE
            $Admin = [Admins]::FindById([Admins], 26)[0]
            $Result = $Admin.Delete()
            if ($Result) {
                PrintSuccessMessage -SuccessMessage "The Admin '$($Admin.first_name)' was successfully deleted."
            }
        #>

        $Sql = "DELETE FROM $($this::TableName) "
        $Sql += "WHERE id='$($this::Database.RealEscapeString($this.id))' "
        $Sql += "LIMIT 1"
        [bool]$Result = $this::Database.Query($Sql, $true)[0]
        return $Result
    }

}

class Admins : DatabaseObject {
    hidden static $TableName = "admins"
    hidden static $DbColumns = [System.Collections.ArrayList]@(
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
