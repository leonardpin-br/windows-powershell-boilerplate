
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
        $record = @{}

        $data_adapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($sql, $this.connection)
        $data_table = New-Object System.Data.DataTable

        try {

            # CREATE, UPDATE or DELETE (CRUD)
            if ($values) {
                Write-Host "The values arraylist is not null"
            }

            # READ (CRUD)
            else {

                # Fills the $data_table with the result set.
                $data_adapter.Fill($data_table)

                # Fills the hashtable.
                for ($i = 0; $i -lt $data_table.Rows.Count; $i++) {

                    for ($j = 0; $j -lt $data_table.Columns.Count; $j++) {
                        $record.Add($data_table.Columns[$j], $data_table.DefaultView[$i].Row.ItemArray[$j])
                    }

                    # Fills the result set.
                    $result_set.Add($record)
                    $record = @{}

                }

            }

        }
        # catch {

        # }

        finally {
            Write-Host "Finally..."
        }



        return $result_set

    }

}

function Main {
    Clear-Host
    $connection_db = [ConnectionDB]::new()
    $sql = "SELECT * FROM admins"
    $result_set = $connection_db.Query($sql, $null)
    $row = $result_set[0]
    $row

    # $row.keys | ForEach-Object{
    #     $message = '{0} is {1}' -f $_, $row[$_]
    #     Write-Output $message
    # }

    # Write-Output "-----------"


    # if ($row.first_name) {
    #     Write-Host "OK"
    # }


    # $ageList = @{}
    # $key = 'Kevin'
    # $value = 36
    # $ageList.add( $key, $value )
    # $ageList.add( 'Alex', 9 )
    # $ageList['Kevin']
    # $ageList['Alex']

    # for ($i = 0; $i -lt $result_set.Count; $i++) {

    #     $row = $result_set[$i]

    #     Write-Host "Test"
    #     Write-Host "$($row['first_name'])"

        #     $message = '{0}' -f $row[$key]
        #     Write-Host $message
            # Write-Host "First name: " $row['first_name']
            # Write-Host "Last name: ${$result_set.last_name}"
            # Write-Host "Email: ${$result_set.email}"
            # Write-Host "Username: ${$result_set.username}"
            # Write-Host "Hashed password: ${$result_set.hashed_password}"
            # Write-Host "-------------------------------------------`n"


    # }
    # Write-Host $result_set.GetType()
}

Main