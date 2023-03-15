


# This is used by some of the functions below
$logonUserSignature =
@'
[DllImport( "advapi32.dll" )]
public static extern bool LogonUser( String lpszUserName,
                                     String lpszDomain,
                                     String lpszPassword,
                                     int dwLogonType,
                                     int dwLogonProvider,
                                     ref IntPtr phToken );
'@



$closeHandleSignature =
@'
[DllImport( "kernel32.dll", CharSet = CharSet.Auto )]
public static extern bool CloseHandle( IntPtr handle );
'@

$revertToSelfSignature = 
@'
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool RevertToSelf();
'@

$AdvApi32 = Add-Type -MemberDefinition $logonUserSignature -Name "AdvApi32" -Namespace "PsInvoke.NativeMethods" -PassThru
$Kernel32 = Add-Type -MemberDefinition $closeHandleSignature -Name "Kernel32" -Namespace "PsInvoke.NativeMethods" -PassThru
$AdvApi32_2  = Add-Type -MemberDefinition $revertToSelfSignature -Name "AdvApi32_2" -Namespace "PsInvoke.NativeMethods" -PassThru
[Reflection.Assembly]::LoadWithPartialName("System.Security")



function IsLocalUserNamePasswordValid()
{
    param(
    [String]$UserName,
    [String]$Password
	  )
	
  	$Logon32ProviderDefault = 0
	$Logon32LogonInteractive = 2
	$tokenHandle = [IntPtr]::Zero       
	$success = $false    
	$DomainName = $null

	#Attempt a logon using this credential
	$success = $AdvApi32::LogonUser($UserName, $DomainName, $Password, $Logon32LogonInteractive, $Logon32ProviderDefault, [Ref] $tokenHandle)            
  	return $success
}

# prompt for password
$plainpassword = Read-Host -AsSecureString

$password = ConvertTo-SecureString $plainpassword -AsPlainText -Force

if (IsLocalUserNamePasswordValid -UserName $env:USERNAME -Password $plainpassword) {
    
} else {
    Write-Host "invalid credentials"
    exit
}

$password = ConvertTo-SecureString $plainpassword -AsPlainText -Force

$c2  = New-Object System.Management.Automation.PSCredential($env:USERNAME,$password)
exit

# test the credential is valid
Test-ComputerSecureChannel -ComputerName localhost -Credential $c2

exit

$credential = New-Object System.Management.Automation.PSCredential ($env:USERNAME, $password)

Test-ComputerSecureChannel -Credential $credential

# the path to stored credential
$credPath = "cred.xml"
if (Test-Path $credPath) {
    $cred = Import-CliXml -Path $credPath
}

# check for stored credential
if (IsLocalUserNamePasswordValid -UserName $env:USERNAME -Password $passwordPlainText) {
    #crendetial is stored, load it 
    $cred = Import-CliXml -Path $credPath
} else {
    # no stored credential: create store, get credential and save it
    $parent = split-path $credpath -parent
    if ( -not ( test-Path $parent ) ) {
        New-Item -ItemType Directory -Force -Path $parent
    }
    $cred = get-credential -Credential $env:USERNAME
    $cred | Export-CliXml -Path $credPath
}

exit

#$creds = Import-Clixml -Path ".\credentials.xml"

#Write-Host "Getting your credentials..."
#$cred = Get-Credential -Credential $env:USERNAME
#$cred | Export-Clixml -Path ".\credentials.xml"
#exit

#Write-Host "write out the password"
#$cred.Password | ConvertFrom-SecureString | Set-Content .\password.txt
#$password = Get-Content .\password.txt | ConvertTo-SecureString



$password = ConvertTo-SecureString -String $passwordPlainText -AsPlainText -Force

$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:USERNAME, $password

#$credential = New-Object System.Management.Automation.PsCredential `
# $cred.UserName,$password


# Check that $credential is not null
if ($creds -eq $null) {
    Write-Host "No credentials were entered."
    exit
}

Write-Host "Checking credentials..."
Test-WSMan -ComputerName localhost -Credential $creds

Test-ComputerSecureChannel -Credential $creds
Write-Host "Done."


#Write-Host $cred.UserName

Write-Host "Exporting credentials to file..."
$cred | Export-Clixml -Path ".\credentials.xml"

Write-Host "Reimporting credentials from file..."
$creds = Import-Clixml -Path ".\credentials.xml"
#$cred = Get-Credential -Credential $env:USERNAME


$username = $cred.username
Write-Host $username



function Validate-Credentials([System.Management.Automation.PSCredential]$credentials)
{
    $pctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, "domain")
    $nc = $credentials.GetNetworkCredential()
    return $pctx.ValidateCredentials($nc.UserName, $nc.Password)
}



try{
    Write-Host "Checking credentials"
    start-process -Credential $cred -FilePath ping -WindowStyle Hidden
    Write-Host "Done."
} catch {
    write-error $_.Exception.Message
    break
}

