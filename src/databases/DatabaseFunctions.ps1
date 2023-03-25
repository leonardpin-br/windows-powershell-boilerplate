# Importing a script:
. "$($PSScriptRoot)\..\..\config\DBCredentials.ps1"
. "$($PSScriptRoot)\..\shared\ValidationFunctions.ps1"
. "$($PSScriptRoot)\..\shared\Functions.ps1"

function Connect-MySQL {
    <#
    .SYNOPSIS
        Connects to the MySQL server.
    #>

    try {

        # Loads the functionality from the MySQL Connector.
        [void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll")

        $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection;

        $Connection.ConnectionString="server=$($DatabaseParameters['server']);user id=$($DatabaseParameters['user']);password=$($DatabaseParameters['password']);database=$($DatabaseParameters['database']);pooling=false"

        $SqlCommand = New-Object MySql.Data.MySqlClient.MySqlCommand

        $Connection.Open()

        $Data = @($Connection, $SqlCommand)
        return $Data

    }

    catch {

        $message = $Error[0].Exception.Message.ToString()

        if ($message -like "*Unable to connect to any of the specified MySQL hosts*") {

            $ErrorMessage = "The MySQL server is not available."
            PrintErrorMessage -ErrorMessage $ErrorMessage

            # Not being able to connect tho the server is a non-terminating error.
            # The line below is necessary to stop execution.
            throw $ErrorMessage

        }

        elseif ($message -like "*Access denied*") {
            $ErrorMessage = "Access denied: Check username and password AND the database name."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }

        else {
            $ErrorMessage = "There was an error with the database connection."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }

    }

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
