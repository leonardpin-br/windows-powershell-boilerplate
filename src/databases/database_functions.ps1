# Importing a script:
. "$($PSScriptRoot)\..\..\config\db_credentials.ps1"
. "$($PSScriptRoot)\..\shared\validation_functions.ps1"
. "$($PSScriptRoot)\..\shared\functions.ps1"

function Connect-MySQL {

    try {

        # Loads the functionality from the MySQL Connector.
        [void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll")

        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection;

        $connection.ConnectionString="server=$($databaseParameters['server']);user id=$($databaseParameters['user']);password=$($databaseParameters['password']);database=$($databaseParameters['database']);pooling=false"

        $sqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand

        $connection.Open()

        $data = @($connection, $sqlCmd)
        return $data

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

    param (
        $Connection
    )

    $isSet = (Is-Set -Variable $Connection)

    # Checks if the connection was set.
    if ( $isSet ) {
        $Connection.Close()
    }

}
