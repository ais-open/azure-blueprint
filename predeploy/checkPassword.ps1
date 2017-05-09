[cmdletbinding()]
Param(
  [Parameter(Mandatory=$true)]
  [string]$password
)


Function checkPassword()    {
  Param(
    [Parameter(Mandatory=$true)]
    [string]$pass
  )
	$passLength = 14
	if ($pass.Length -ge $passLength) {
    $pw2test = $pass
		$isGood = 0
		If ($pw2test -match "[^a-zA-Z0-9]"){
			$isGood++
    }
		If ($pw2test -match "[0-9]") {
			$isGood++
    }
		If ($pw2test -cmatch "[a-z]") {
			$isGood++
    }
		If ($pw2test -cmatch "[A-Z]"){
			$isGood++
    }
		If ($isGood -ge 3) {
      return 
    } Else {
      Throw "Password does not meet complexity requirements"
    }
  } Else {
    "Password is not long enough - Passwords must be at least " + $passLength + " characters long"
    Throw "Password does not meet complexity requirements"
  }

}

checkPassword($password)
