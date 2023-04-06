function Is-Null($Variable) {
    <#
    .SYNOPSIS
        Mimics loosely the behavior of the PHP function is_null().
    .DESCRIPTION
        Finds whether a variable is $null.
    .PARAMETER $Variable
        The variable being evaluated.
    .OUTPUTS
        Returns $true if value is $null, $false otherwise.
    #>

    if ($null -eq $Variable) {
        return $true
    }
    return $false
}

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