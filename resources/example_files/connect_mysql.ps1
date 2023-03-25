# Connect to MySQL
# https://dev.mysql.com/downloads/connector/net/
# https://social.technet.microsoft.com/wiki/pt-br/contents/articles/14100.executando-comandos-mysql-e-mssql-no-powershell.aspx#MySQL
# https://www.cdata.com/kb/tech/mysql-ado-powershell.rst

# Starts clearing the terminal.
Clear-Host

# Loads the functionality from the MySQL Connector.
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll")

$connection = New-Object MySql.Data.MySqlClient.MySqlConnection;
$server = "localhost"
$user = "webuser"
$password = "secretpassword"
$database = "chain_gang"
$connection.ConnectionString="server=$server;user id=$user;password=$password;database=$database;pooling=false"

$sqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand

$sql = "SELECT * FROM admins WHERE id='1'"

$sqlCmd.CommandText = $sql
$sqlCmd.Connection = $connection

$connection.open()
$sqlReader = $sqlCmd.ExecuteReader()
# $sqlReader = $sqlCmd.ExecuteNonQuery()

while($sqlReader.Read()) {
    $record = [hashtable]@{
        'id'=$sqlReader[0];
        'first_name'=$sqlReader[1];
        'last_name'=$sqlReader[2];
        'email'=$sqlReader[3];
        'username'=$sqlReader[4];
        'hashed_password'=$sqlReader[5];
    }
    Write-Output "ID: $($record.id)"
    Write-Output "First name: $($record.first_name)"
    Write-Output "Last name: $($record.last_name)"
    Write-Output "Email: $($record.email)"
    Write-Output "Username: $($record.username)"
    Write-Output "Hashed password: $($record.hashed_password)"

    Write-Output ""
}







$connection.Close()