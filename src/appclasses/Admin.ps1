<#
.SYNOPSIS
    Example class representing an admin.
.PARAMETER [System.Collections.Hashtable]$Properties
    Hashtable, with keys corresponding to the admins table columns. The keys can
    be empty.
.OUTPUTS
    An instance of Admin.
.EXAMPLE
    [System.Collections.Hashtable]$Properties = @{
        first_name = "Leonardo";
        last_name = "Pinheiro";
        email = "info@leonardopinheiro.net";
        username = "leo";
        password = "secretpassword";
        confirm_password = "secretpassword";
    }

    # Creates an object in memory.
    $Admin = [Admins]::new($Properties)
    $Admin.hashed_password = "zzzzzzzzzz"

    # Saves the object in memory in the database.
    $Result = $Admin.Save()
    if (-not $Result) {
        PrintErrorMessage -ErrorMessage "The first error in the validation was: '$($Admin.Errors[0])'. There may be more."
    }
    else {
        PrintSuccessMessage -SuccessMessage "Object saved."
    }
#>

. "$($PSScriptRoot)\..\databases\DatabaseObject.ps1"


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
