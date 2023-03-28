. "$($PSScriptRoot)\DBCredentials.ps1"
. "$($PSScriptRoot)\..\src\databases\DatabaseFunctions.ps1"
. "$($PSScriptRoot)\..\src\databases\DatabaseObject.ps1"

$MySqlData = "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll"

$Server = $DatabaseParameters["server"]
$User = $DatabaseParameters["user"]
$Password = $DatabaseParameters["password"]
$Database = $DatabaseParameters["database"]

$database = Connect-MySQL -MySqlData $MySqlData -Server $Server -User $User -Password $Password -Database $Database
[DatabaseObject]::SetDatabase([DatabaseObject], $Database)