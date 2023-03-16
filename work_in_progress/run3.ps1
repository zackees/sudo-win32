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


# Get user input
# $Command = Read-Host "Enter Command"

$Command = "python gen.py"

$CurrDirectory = Get-Location

# Create named pipes for stdout and stderr
$pipeNameOut = [System.Guid]::NewGuid().ToString()
$pipeNameErr = [System.Guid]::NewGuid().ToString()
$pipeServerOut = New-Object System.IO.Pipes.NamedPipeServerStream($pipeNameOut, [System.IO.Pipes.PipeDirection]::InOut, 1, [System.IO.Pipes.PipeTransmissionMode]::Byte, [System.IO.Pipes.PipeOptions]::Asynchronous)
$pipeServerErr = New-Object System.IO.Pipes.NamedPipeServerStream($pipeNameErr, [System.IO.Pipes.PipeDirection]::InOut, 1, [System.IO.Pipes.PipeTransmissionMode]::Byte, [System.IO.Pipes.PipeOptions]::Asynchronous)

# Define the script block to run the command and stream the output through the named pipes
$ScriptBlock = {
    param($Command, $pipeNameOut, $pipeNameErr, $CurrDirectory)

    $pipeClientOut = New-Object System.IO.Pipes.NamedPipeClientStream(".", $pipeNameOut, [System.IO.Pipes.PipeDirection]::InOut, [System.IO.Pipes.PipeOptions]::None)
    $pipeClientErr = New-Object System.IO.Pipes.NamedPipeClientStream(".", $pipeNameErr, [System.IO.Pipes.PipeDirection]::InOut, [System.IO.Pipes.PipeOptions]::None)

    $pipeClientOut.Connect()
    $pipeClientErr.Connect()

    $writerOut = New-Object System.IO.StreamWriter($pipeClientOut)
    $writerErr = New-Object System.IO.StreamWriter($pipeClientErr)

    $originalOut = [Console]::Out
    $originalErr = [Console]::Error

    [Console]::SetOut($writerOut)
    [Console]::SetError($writerErr)

    Set-Location $CurrDirectory

    $exitCode = 0
    try {
        Invoke-Expression $Command
    } catch {
        $exitCode = 1
    }


    [Console]::SetOut($originalOut)
    [Console]::SetError($originalErr)

    $writerOut.Dispose()
    $writerErr.Dispose()

    $pipeClientOut.Dispose()
    $pipeClientErr.Dispose()
    return $exitCode
}


# Run the command using Start-Job with the specified credential
$Job = Start-Job -ScriptBlock $ScriptBlock -Credential $ValidCredential -ArgumentList $Command, $pipeNameOut, $pipeNameErr, $CurrDirectory

# Connect to the named pipes and display the output in real-time
$pipeServerOut.WaitForConnection()
$pipeServerErr.WaitForConnection()

$readerOut = New-Object System.IO.StreamReader($pipeServerOut)
$readerErr = New-Object System.IO.StreamReader($pipeServerErr)

do {
    if ($pipeServerOut.IsConnected) {
        $stdout = $readerOut.ReadLine()
        if ($stdout) { Write-Output $stdout }
    }

    if ($pipeServerErr.IsConnected) {
        $stderr = $readerErr.ReadLine()
        if ($stderr) { Write-Error $stderr }
    }

    Start-Sleep -Milliseconds 100
} while ($Job.State -eq 'Running')



$stdout = $readerOut.ReadLine()
if ($stdout) { Write-Output $stdout }

$stderr = $readerErr.ReadLine()
if ($stderr) { Write-Error $stderr }

# Get any remaining output from the job
$jobOutput = Receive-Job $Job
$exitCode = $jobOutput[-1]

# Print the exit code
Write-Host "Exit code: $exitCode"
# Write-Host "FInished job: $Job"
# Write-Host "Job state: $Job"

# Clean up resources
Remove-Job $Job
$readerOut.Dispose()
$readerErr.Dispose()
$pipeServerOut.Dispose()
$pipeServerErr.Dispose()
