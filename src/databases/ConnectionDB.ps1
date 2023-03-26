. "$($PSScriptRoot)\..\shared\Functions.ps1"

class ConnectionDB {
    <#
    .SYNOPSIS
        Represents a connection between Powershell and a MySQL database.

    .DESCRIPTION
        Mimics (loosely and in a very crud way) the mysqli (PHP) class.

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

    .LINK
        # Automate MySQL Integration Tasks from PowerShell
        https://www.cdata.com/kb/tech/mysql-ado-powershell.rst

    .LINK
        # Powershell: Some examples to use a MySQL Database
        https://michlstechblog.info/blog/powershell-some-examples-to-use-a-mysql-database/

    .LINK
        # 6.1.4 Working with Parameters
        https://dev.mysql.com/doc/connector-net/en/connector-net-tutorials-parameters.html
    #>

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
        #>

        # ArrayList that will store the results (one Hashtable for each row).
        $ResultSet = [System.Collections.ArrayList]@()
        $Record = [System.Collections.Hashtable]@{}

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

            }

            # READ (CRUD)
            else {

                # Creates the data adapter for read queries.
                $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Sql, $this.Connection)

                # Creates the data table for read queries.
                $DataTable = New-Object System.Data.DataTable

                # Fills the $DataTable with the result set.
                $DataAdapter.Fill($DataTable)

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

# function Main {
#     Clear-Host

#     # READ
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "SELECT * FROM admins"
#     $ResultSet = $ConnectionDb.Query($Sql, $null)


#     for ($i = 0; $i -lt $ResultSet.Count; $i++) {

#         $row = $ResultSet[$i]

#         Write-Host "ID: $($row["id"])"
#         Write-Host "First name: $($row["first_name"])"
#         Write-Host "Last name: $($row["last_name"])"
#         Write-Host "Email: $($row["email"])"
#         Write-Host "Username: $($row["username"])"
#         Write-Host "Hashed password: $($row["hashed_password"])"
#         Write-Host "-------------------------------------------`n"

#     }

#     # CREATE
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "INSERT INTO admins (first_name, last_name, email, username, hashed_password) "
#     $Sql += "VALUES ('Leonardo', 'Pinheiro', 'info@leonardopinheiro.net', 'leo', 'zzzz')"

#     $ResultSet = $ConnectionDb.Query($Sql, $True)

#     # UPDATE
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "UPDATE admins "
#     $Sql += "SET username = 'leo' "
#     $Sql += "WHERE id = 22"

#     $ResultSet = $ConnectionDb.Query($Sql, $True)
#     if ($ConnectionDb.AffectedRows -eq 0) {
#         PrintErrorMessage -ErrorMessage "The ID was not found."
#     }

#     # DELETE
#     # ==========================================================================
#     $ConnectionDb = [ConnectionDB]::new()
#     $Sql = "DELETE FROM admins "
#     $Sql += "WHERE id = 22 "
#     $Sql += "LIMIT 1"

#     $ResultSet = $ConnectionDb.Query($Sql, $True)
#     if ($ConnectionDb.AffectedRows -eq 0) {
#         PrintErrorMessage -ErrorMessage "The ID was not found."
#     }

# }

# Main