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
    If ($pw2test -match " "){
    "Password cannot contain spaces"
      Throw "Password does not meet complexity requirements"
    } Else {
      $isGood++
    }
		If ($pw2test -match "[^a-zA-Z0-9]"){
			$isGood++
    } Else {
      "Password must contain a special character"
        Throw "Password does not meet complexity requirements"
    }
		If ($pw2test -match "[0-9]") {
			$isGood++
    } Else {
      "Password must contain a numerical character"
        Throw "Password does not meet complexity requirements"
    }
		If ($pw2test -cmatch "[a-z]") {
			$isGood++
    } Else {
      "Password must contain a lowercase letter"
        Throw "Password does not meet complexity requirements"
    }
		If ($pw2test -cmatch "[A-Z]"){
			$isGood++
    } Else {
      "Password must contain an uppercase character"
        Throw "Password does not meet complexity requirements"
    }
		If ($isGood -ge 4) {

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
