function Is-Set {
    <#
        .SYNOPSIS
            Mimics the behaviour of the PHP's function isset().
    #>

    $numOfArgs = $args.Length

    for ($i=0; $i -lt $numOfArgs; $i++) {

        if ($args[$i] -eq $null) {
            return $false
        }

    }

    return $true

}