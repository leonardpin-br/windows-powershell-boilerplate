<#
.SYNOPSIS
    A collection of database related functions.
#>

# Importing a script:
. "$($PSScriptRoot)\ConnectionDB.ps1"
. "$($PSScriptRoot)\..\shared\ValidationFunctions.ps1"

function Connect-MySQL {
    <#
    .SYNOPSIS
        Connects to the MySQL server.
    .PARAMETER MySqlData
        Complete path to the MySQL Connector .dll file.
    .PARAMETER Server
        Server name or IP.
    .PARAMETER User
        The username.
    .PARAMETER Password
        The password.
    .PARAMETER Database
        The database name.
    .OUTPUTS
        ConnectionDB instance object.
    .EXAMPLE
        $Connection = [ConnectionDB]::new($MySqlData, $Server, $User, $Password, $Database)
    #>

    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$MySqlData,

        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Server,

        [Parameter(Position = 2, Mandatory = $true)]
        [String]$User,

        [Parameter(Position = 3, Mandatory = $true)]
        [String]$Password,

        [Parameter(Position = 4, Mandatory = $true)]
        [String]$Database
    )

    $Connection = [ConnectionDB]::new($MySqlData, $Server, $User, $Password, $Database)

    return $Connection

}

function Disconnect-MySQL {
    <#
    .SYNOPSIS
        Disconnects from the MySQL server.
    .PARAMETER Connection
        [ConnectionDB] ConnectionDB instance object.
    .EXAMPLE
        try {
            # CRUD operations
        }

        catch {
            # Print error messages.
            # throw
        }

        finally {
            Disconnect-MySQL -Connection $this.Connection
        }
    #>

    param (
        # The connection object.
        [Parameter(Position = 0, Mandatory = $true)]
        $Connection
    )

    $isSet = (Is-Set -Variable $Connection)

    # Checks if the connection was set.
    if ( $isSet ) {
        $Connection.Close()
    }

}
