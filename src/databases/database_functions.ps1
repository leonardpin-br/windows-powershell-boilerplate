# Importing a script:
. "$($PSScriptRoot)\..\..\config\db_credentials.ps1"
. "$($PSScriptRoot)\..\shared\validation_functions.ps1"
. "$($PSScriptRoot)\..\shared\functions.ps1"

function Connect-MySQL {

    try {
        # Loads the functionality from the MySQL Connector.
        [void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll")

        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection;

        # $connection.ConnectionString="server={0};user id={1};password={2};database={3};pooling=false" -f $databaseParameters['server'], $databaseParameters['user'], $databaseParameters['password'], $databaseParameters['database']
        $connection.ConnectionString="server=$($databaseParameters['server']);user id=$($databaseParameters['user']);password=$($databaseParameters['password']);database=$($databaseParameters['database']);pooling=false"

        $sqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand

        $connection.open()

        $data = @($connection, $sqlCmd)
        return $data
    }

    catch {

        $message = $Error[0].Exception.Message.ToString()

        if ($message -like "*Unable to connect to any of the specified MySQL hosts*") {
            PrintErrorMessage -ErrorMessage "The MySQL server is not available."
        }

        elseif ($message -like "*Access denied*") {
            PrintErrorMessage -ErrorMessage "Access denied: Check username and password AND the database name."
        }

        else {
            PrintErrorMessage -ErrorMessage "There was an error with the database connection."
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