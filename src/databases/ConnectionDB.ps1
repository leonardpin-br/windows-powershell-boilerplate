<#
.SYNOPSIS
    Class that represents a connection between Powershell and a MySQL database.
.DESCRIPTION
    Mimics (loosely and in a very crud way) the mysqli (PHP) class.
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
.LINK
    # Automate MySQL Integration Tasks from PowerShell
    https://www.cdata.com/kb/tech/mysql-ado-powershell.rst

    # Powershell: Some examples to use a MySQL Database
    https://michlstechblog.info/blog/powershell-some-examples-to-use-a-mysql-database/

    # 6.1.4 Working with Parameters
    https://dev.mysql.com/doc/connector-net/en/connector-net-tutorials-parameters.html
.EXAMPLE
    # The script containing this class must be imported:
    . "$($PSScriptRoot)\ConnectionDB.ps1"

    ...

    $Connection = [ConnectionDB]::new($MySqlData, $Server, $User, $Password, $Database)
#>


. "$($PSScriptRoot)\..\shared\Functions.ps1"


class ConnectionDB {

    [int32]$AffectedRows = 0
    [int32]$InsertId = 0
    $Connection
    $SqlCommand

    ConnectionDB([String]$MySqlData, [String]$Server, [String]$User, [String]$Password, [String]$Database) {

        $this.LoadConnector($MySqlData)

        # Tries to connect to the MySQL database.
        # ----------------------------------------------------------------------
        try {

            $this.Connection = New-Object MySql.Data.MySqlClient.MySqlConnection;

            $ConnectionString = "server=$($Server);user id=$($User);password=$($Password);database=$($Database);pooling=false"
            $this.Connection.ConnectionString = $ConnectionString

            $this.SqlCommand = New-Object MySql.Data.MySqlClient.MySqlCommand

            $this.Connection.Open()
            $this.Connection.Close()

        }

        catch {
            [String]$ErrorMessage = $_.Exception.Message.ToString()
            $ErrorMessage = $ErrorMessage.Remove(0, 47)

            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }
    }

    [void]LoadConnector([String]$MySqlData) {
        # Tries to load the MySQL connector.
        # ----------------------------------------------------------------------
        try {
            # Loads the functionality from the MySQL Connector.
            [void][System.Reflection.Assembly]::LoadFrom($MySqlData)
        }
        catch {
            $ErrorMessage = "Unable to load the MySQL Connector from `"$($MySqlData)`"."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }
    }

    [System.Collections.ArrayList]Query([String]$Sql, [Boolean]$IsDataChange) {
        <#
        .SYNOPSIS
            Performs a query on the database.
        .PARAMETER [String]$Sql
            The query to be executed.
        .PARAMETER [Boolean]$IsDataChange
            $true, if it is going to change data. $false otherwise.
        .OUTPUTS
            Returns $false on failure.
            For successful queries which produce a result set, such as SELECT,
            SHOW, DESCRIBE or EXPLAIN, will return an ArrayList with all records
            as Hashtables.
            For other successful queries, will return $true.
        .EXAMPLE
            # Example 1:
            [System.Collections.ArrayList]$ResultSet = $TargetType::Database.Query($Sql, $false)
            if ($ResultSet[0] -eq $false) { ... }

            # Example 2:
            $ResultSet = $TargetType::Database.Query($Sql, $false)

            # Example 3:
            $Result = $this.GetType()::Database.Query($Sql, $true)[0]

            # Example 4:
            [bool]$Result = $this::Database.Query($Sql, $true)[0]
        #>

        # ArrayList that will store the results (one Hashtable for each row).
        [System.Collections.ArrayList]$ResultSet = @()
        [System.Collections.Hashtable]$Record = @{}

        $this.Connection.Open()

        if ($this.Connection.State -ne "Open") {

            $ErrorMessage = "The connection with the database is not open."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage

        }

        try {

            # CREATE, UPDATE or DELETE (CRUD)
            if ($IsDataChange) {

                $this.SqlCommand.Connection = $this.Connection
                $this.SqlCommand.CommandText = $Sql

                $this.AffectedRows = $this.SqlCommand.ExecuteNonQuery()
                $this.InsertId = $this.SqlCommand.LastInsertedId

                if ($this.AffectedRows -ne 0) {
                    $NonQueryResult = $true
                    $ResultSet.Add($NonQueryResult)
                }
                else {
                    $NonQueryResult = $false
                    $ResultSet.Add($NonQueryResult)
                }

            }

            # READ (CRUD)
            else {

                # Creates the data adapter for read queries.
                $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Sql, $this.Connection)

                # Creates the data table for read queries.
                $DataTable = New-Object System.Data.DataTable

                # Fills the $DataTable with the result set.
                $DataAdapter.Fill($DataTable)

                # If the query was unsuccessful, returns the ArrayList with $false in it.
                if ($DataTable.Rows.Count -eq 0) {
                    $QueryResult = $false
                    $ResultSet.Add($QueryResult)
                    return $ResultSet
                }

                # Fills the hashtable.
                for ($i = 0; $i -lt $DataTable.Rows.Count; $i++) {

                    for ($j = 0; $j -lt $DataTable.Columns.Count; $j++) {

                        # The quotes "$(...)" are VERY IMPORTANTE!
                        $Record.Add("$($DataTable.Columns[$j])", $DataTable.DefaultView[$i].Row.ItemArray[$j])

                    }

                    # Fills the result set.
                    $ResultSet.Add($Record)
                    $Record = @{}

                }

            }

        }

        catch {
            $ErrorMessage = $_.Exception.Message.ToString()
            $ErrorMessage = $ErrorMessage -replace ".*: "

            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage
        }

        finally {
            Disconnect-MySQL -Connection $this.Connection
        }

        return $ResultSet

    }

    [String]RealEscapeString([String]$StringToEscape) {
        <#
        .SYNOPSIS
            Roughly does the same as the ``mysqli::real_escape_string`` method,
            that is, escapes a string. It is meant to be used before sending it to
            the database.

        .LINK
            # Function to escape characters in paths
            https://stackoverflow.com/a/46037546/3768670
        #>

        return [Management.Automation.WildcardPattern]::Escape($StringToEscape)
    }

}
