# References:
# Automate MySQL Integration Tasks from PowerShell
# https://www.cdata.com/kb/tech/mysql-ado-powershell.rst

. "$($PSScriptRoot)\database_functions.ps1"

class ConnectionDB {
    [int32]$affected_rows = 0
    [int32]$insert_id = 0
    $connection
    $sqlCmd

    ConnectionDB() {
        $connection_and_sqlCmd = Connect-MySQL
        $this.connection = $connection_and_sqlCmd[0]
        $this.sqlCmd = $connection_and_sqlCmd[1]
    }

    # Performs a query on the database.
    [System.Collections.ArrayList]Query([string]$sql, $values) {

        # ArrayList that will store the results (one Hashtable for each row).
        $result_set = [System.Collections.ArrayList]@()
        $record = [System.Collections.Hashtable]@{}

        try {

            # CREATE, UPDATE or DELETE (CRUD)
            if ($values) {
                Write-Host "The values arraylist is not null"
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
            Write-Host "Catch..."
        }

        finally {
            Disconnect-MySQL -Connection $this.connection
        }

        return $result_set

    }

}

function Main {
    Clear-Host
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

}

Main