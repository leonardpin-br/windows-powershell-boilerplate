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
        [String] Complete path to the MySQL Connector .dll file.
    .PARAMETER Server
        [String] Server name or IP.
    .PARAMETER User
        [String] The username.
    .PARAMETER Password
        [String] The password.
    .PARAMETER Database
        [String] The database name.
    .OUTPUTS
        ConnectionDB instance object.
    #>

    param(
        [String]$MySqlData,
        [String]$Server,
        [String]$User,
        [String]$Password,
        [String]$Database
    )

    $Connection = [ConnectionDB]::new($MySqlData, $Server, $User, $Password, $Database)

    return $Connection

}

function Disconnect-MySQL {
    <#
    .SYNOPSIS
        Disconnects from the MySQL server.
    #>

    param (
        # The connection object.
        $Connection
    )

    $isSet = (Is-Set -Variable $Connection)

    # Checks if the connection was set.
    if ( $isSet ) {
        $Connection.Close()
    }

}
