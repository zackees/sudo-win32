
function Check-Credentials {
    param (
        [string]$CredentialPath = ".\credentials.xml",
        [string]$InUserName = $env:USERNAME
    )

    $newCredentials = $false

    try {
        $cred = Import-Clixml -Path $CredentialPath
    } catch {
        Write-Host "No credentials were entered."
        $cred = Get-Credential -Credential $InUserName
        $cred = Import-Clixml -Path $CredentialPath
    }

    $Credential = Import-Clixml -Path $CredentialPath
    $Username = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().Password

    # Add the System.DirectoryServices.AccountManagement namespace
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    # Check if the credentials are valid
    $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Machine
    $PrincipalContext = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ContextType

    $IsValid = $PrincipalContext.ValidateCredentials($Username, $Password)

    if ($IsValid) {
        if ($newCredentials) {
            $cred | Export-Clixml -Path $CredentialPath
            Write-Host "Credentials exported to file."
        }
        return $Credential
    } else {
        return $null
    }
}

$ValidCredential = Check-Credentials -CredentialPath ".\credentials.xml"
if ($ValidCredential) {
    Write-Host "Valid credential found."
} else {
    Write-Host "No valid credential found."
}