function Test-CredentialExpiration {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$CredentialWithTimestamp,

        [Parameter(Mandatory = $true)]
        [TimeSpan]$ExpirationTime
    )

    $Credential = $CredentialWithTimestamp.Credential
    $CurrentTime = Get-Date
    $CredentialAge = $CurrentTime - $CredentialWithTimestamp.Timestamp

    if ($CredentialAge -gt $ExpirationTime) {
        Write-Host "Credential has expired."
        return $false
    } else {
        return $true
    }
}

function Check-Credentials {
    param (
        [string]$CredentialPath = ".\credentials.xml",
        [string]$InUserName = $env:USERNAME,
        [TimeSpan]$ExpirationTime = (New-TimeSpan -Minutes 15)
    )

    $newCredentials = $false

    try {
        $credWithTimestamp = Import-Clixml -Path $CredentialPath
        if (-not (Test-CredentialExpiration -CredentialWithTimestamp $credWithTimestamp -ExpirationTime $ExpirationTime)) {
            throw "Credential has expired."
        }
    } catch {
        $cred = Get-Credential -Credential $InUserName
        $credWithTimestamp = @{
            Credential = $cred
            Timestamp = Get-Date
        }
        $credWithTimestamp | Export-Clixml -Path $CredentialPath
    }

    $Credential = $credWithTimestamp.Credential
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
            $credWithTimestamp | Export-Clixml -Path $CredentialPath
            Write-Host "Credentials exported to file."
        }
        return $Credential
    } else {
        return $null
    }
}

$ValidCredential = Check-Credentials -CredentialPath ".\credentials.xml" -ExpirationTime (New-TimeSpan -Minutes 15)
if ($ValidCredential) {
    Write-Host "Valid credential found."
} else {
    Write-Host "No valid credential found."
    exit 1
}

# Everything becomes easier when using a batch file to run the command.
$Command = "run.bat"
$CurrDirectory = Get-Location

# Create a job to run the command
$process = Start-Process -FilePath "run.bat" -PassThru -Wait -WorkingDirectory $CurrDirectory -NoNewWindow
$exitCode = $process.ExitCode
# Print the exit code
Write-Host "Exit code: $exitCode"