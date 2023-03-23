function Is-Set {

    $numOfArgs = $args.Length

    for ($i=0; $i -lt $numOfArgs; $i++) {

        if ($args[$i] -eq $null) {
            return $false
        }

    }

    return $true

}