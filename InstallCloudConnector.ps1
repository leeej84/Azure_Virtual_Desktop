[CmdletBinding(SupportsShouldProcess=$True)]
param(
    $APIID,
    $APIKey,
    $CustomerName
    
)
$FileName = "cwcconnector.exe"
$Path = "C:Temp"
$UnattendedArgs = "/q /Customer:$CustomerName /ClientID:$APIID /ClientSecret:$APIKey /AcceptTermsOfService:true"
$url = "https://downloads.cloud.com/$CustomerName/connector/cwcconnector.exe"

Write-Verbose "Downloading $Vendor $Product $Version" -Verbose
New-Item -Path $Path -ItemType Directory -Force
Invoke-WebRequest -Uri $url -OutFile $Path$FileName

$ExitCode = (Start-Process "$Path$FileName" $UnattendedArgs -Wait -Passthru).ExitCode
Return $ExitCode