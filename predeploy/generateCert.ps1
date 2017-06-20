## This script generates a self-signed certificate

$filePath = Read-Host "Enter path to store certificate file (e.g., C:\temp)"
$certPassword = Read-Host -assecurestring "Enter certificate password"

$cert = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname contoso.com
$path = 'cert:\localMachine\my\' + $cert.thumbprint
$certPath = $filePath + '\cert.pfx'
$outFilePath = $filePath + '\cert.txt'
Export-PfxCertificate -cert $path -FilePath $certPath -Password $certPassword
$fileContentBytes = get-content $certPath -Encoding Byte
[System.Convert]::ToBase64String($fileContentBytes) | Out-File $outFilePath