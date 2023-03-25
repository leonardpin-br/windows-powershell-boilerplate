function Is-Set {
    <#
        .SYNOPSIS
            Mimics the behaviour of the PHP's function isset().
    #>

    $NumberOfArguments = $Args.Length

    for ($i=0; $i -lt $NumberOfArguments; $i++) {

        if ($null -eq $Args[$i]) {
            return $false
        }

    }

    return $true

}