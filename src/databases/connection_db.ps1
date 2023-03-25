# References:


. "$($PSScriptRoot)\database_functions.ps1"
. "$($PSScriptRoot)\..\shared\functions.ps1"

class ConnectionDB {
    <#
    .SYNOPSIS
        Mimics (loosely and in a very crud way) the mysqli (PHP) class.

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


    [int32]$affected_rows = 0
    [int32]$insert_id = 0
    $connection
    $sqlCmd

    ConnectionDB() {
        $connection_and_sqlCmd = Connect-MySQL
        $this.connection = $connection_and_sqlCmd[0]
        $this.sqlCmd = $connection_and_sqlCmd[1]
    }

    [System.Collections.ArrayList]Query([String]$sql, [Boolean]$is_data_change) {
        <#
        .SYNOPSIS
            Performs a query on the database.
        #>

        # ArrayList that will store the results (one Hashtable for each row).
        $result_set = [System.Collections.ArrayList]@()
        $record = [System.Collections.Hashtable]@{}

        if ($this.connection.State -ne "Open") {

            $ErrorMessage = "The connection with the database is not open."
            PrintErrorMessage -ErrorMessage $ErrorMessage
            throw $ErrorMessage

        }

        try {


            # CREATE, UPDATE or DELETE (CRUD)
            if ($is_data_change) {

                $this.sqlCmd.Connection = $this.connection
                $this.sqlCmd.CommandText = $sql

                $this.affected_rows = $this.sqlCmd.ExecuteNonQuery()
                $this.insert_id = $this.sqlCmd.LastInsertedId

            }

            # READ (CRUD)
            else {

                # Creates the data adapter for read queries.
                $data_adapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($sql, $this.connection)

                # Creates the data table for read queries.
                $data_table = New-Object System.Data.DataTable

                # Fills the $data_table with the result set.
                $data_adapter.Fill($data_table)

                # Fills the hashtable.
                for ($i = 0; $i -lt $data_table.Rows.Count; $i++) {

                    for ($j = 0; $j -lt $data_table.Columns.Count; $j++) {

                        # The quotes "$(...)" are VERY IMPORTANTE!
                        $record.Add("$($data_table.Columns[$j])", $data_table.DefaultView[$i].Row.ItemArray[$j])

                    }

                    # Fills the result set.
                    $result_set.Add($record)
                    $record = @{}

                }

            }

        }

        catch {
            $ErrorType = $Error[0].Exception.GetType()
            Write-Host -ForegroundColor Yellow $ErrorType
            $ErrorMessage = $_.Exception.Message
            Write-Host $ErrorMessage

            # System.Management.Automation.MethodInvocationException
            # Exception calling "ExecuteNonQuery" with "0" argument(s): "Table 'chain_gang.adminszzzz' doesn't exist"

            # System.Management.Automation.MethodInvocationException
            # Exception calling "ExecuteNonQuery" with "0" argument(s): "Unknown column 'noname' in 'field list'"
        }

        finally {
            Disconnect-MySQL -Connection $this.connection
        }

        return $result_set

    }

    [String]RealEscapeString([String]$string_to_escape) {
        <#
        .SYNOPSIS
            Roughly does the same as the ``mysqli::real_escape_string`` method,
            that is, escapes a string. It is meant to be used before sending it to
            the database.

        .LINK
            # Function to escape characters in paths
            https://stackoverflow.com/a/46037546/3768670
        #>

        return [Management.Automation.WildcardPattern]::Escape($string_to_escape)
    }

}

function Main {
    Clear-Host

    # READ
    # ==========================================================================
    $connection_db = [ConnectionDB]::new()
    $sql = "SELECT * FROM admins"
    $result_set = $connection_db.Query($sql, $null)


    for ($i = 0; $i -lt $result_set.Count; $i++) {

        $row = $result_set[$i]

        Write-Host "ID: $($row["id"])"
        Write-Host "First name: $($row["first_name"])"
        Write-Host "Last name: $($row["last_name"])"
        Write-Host "Email: $($row["email"])"
        Write-Host "Username: $($row["username"])"
        Write-Host "Hashed password: $($row["hashed_password"])"
        Write-Host "-------------------------------------------`n"

    }

    # CREATE
    # ==========================================================================
    # $connection_db = [ConnectionDB]::new()
    # $sql = "INSERT INTO admins (first_name, last_name, email, username, hashed_password) "
    # $sql += "VALUES ('Leonardo', 'Pinheiro', 'info@leonardopinheiro.net', 'leo', 'zzzz')"

    # $result_set = $connection_db.Query($sql, $true)

    # UPDATE
    # ==========================================================================
    # $connection_db = [ConnectionDB]::new()
    # $sql = "UPDATE admins "
    # $sql += "SET username = 'leo' "
    # $sql += "WHERE id = 29"

    # $result_set = $connection_db.Query($sql, $true)

    # TODO
    # Catch block inside Query

}

Main