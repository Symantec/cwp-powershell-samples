<#
.SYNOPSIS
  CWP Agent Version

.DESCRIPTION
  Script to find out available agent version for all/particular OS on CWP portal under download section

.PARAMETER <>
    The x of the .

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0.0
  Author:         Alex Hedley
                  Protirus UK Ltd
                  info@protirus.com
  Creation Date:  29/03/2019
  Release Date:   dd/mm/yyyy
  Purpose/Change: Initial script release
  
.EXAMPLE
  Call '' to 
#>

#=================== Dependencies ==========================
. "$PSScriptRoot\logging.ps1"
. "$PSScriptRoot\cwp_token.ps1"
#=================== Dependencies ==========================

#region Initialisations
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

$DebugPreference = 'Continue' #'SilentlyContinue'

$AgentVersionList = @('all', 'centos6', 'centos7', 'rhel6', 'rhel7', 'ubuntu14', 'ubuntu16', 'amazonlinux', 'windows', 'oel7', 'oel6')

#endregion Initialisations

#region Declarations
#----------------------------------------------------------[Declarations]----------------------------------------------------------

$ScriptVersion = "1.0"

#Log File Info
$LogFilePath = $PSScriptRoot
$LogFile = $LogFilePath + "\" + $MyInvocation.MyCommand.Name + "_" + (Get-Date -Format yyyy-MM-dd) + ".log"

#endregion Declarations

#region Modules
#------------------------------------------------------------[Modules]-------------------------------------------------------------
#endregion Modules

#region Functions
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Get-AgentVersion
{
    <#
    .PARAMETER ServerUrl
        The ServerUrl from your Tenant
    .PARAMETER Platform
        The Platform from your Tenant
    
    .EXAMPLE
        Get-AgentVersion "https://scwp.securitycloud.symantec.com" "All"
        # Platforms - All, centos6, centos7, rhel6, rhel7, ubuntu14, ubuntu16, amazonlinux, windows, oel7, oel6
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerUrl,
        
        [Parameter(Mandatory=$true)]
        [string]$Platform
    )

    Begin
    {}
    Process
    {
        if (!$AgentVersionList.Contains($Platform)) {
            $message = "Invalid Platform choice. Choice should be all/rhel6/rhel7/centos6/centos7/oel6/oel7/ubuntu14/ubuntu16/amazonlinux/windows"
            Write-Host -ForegroundColor White -BackgroundColor Red $message
            Log-Message $message Debug
            
            return $null
        }
        try
        {
            $AgentUrl = ""
            if ($Platform.ToLower() -eq "all") {
                $AgentUrl = $ServerUrl + '/dcs-service/dcscloud/v1/agents/packages/platform/all'
            } else {
                $AgentUrl = $ServerUrl + '/dcs-service/dcscloud/v1/agents/packages/latestversion/platform/'
                $AgentUrl = $AgentUrl + $Platform
            }
            
            $AssetHeader = @{
                'content-type' = 'application/json'
                'Authorization' =  $CWPAuthenticationToken
                'x-epmp-customer-id' = $CustomerID
                'x-epmp-domain-id' = $DomainID
            }

        #   response = requests.get(urlagentversion, headers=headeragentversion)
        #   if response.status_code != 200:
        #         print ("Get agent version API call failed \n")
        #         exit()
        #   elif response.status_code == 200:
        #           print ("Get agent version call API call is successful \n")
        #   outputplatformcheck = {}
        #   outputplatformcheck = response.json()
        #   print (outputplatformcheck)

            $response = Invoke-RestMethod -Uri $AgentUrl -Method GET -Headers $AssetHeader
            # Check the status code.
            return $response
        }
        catch
        {
            Log-Message $Error.item(0) Debug
        }
        finally
        {}
    }
    End
    {}
}

#endregion Functions

#region Execution
#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Message "Script Started" Debug

$authFile = Join-Path $PSScriptRoot 'CWPAuth.ini'
if(![System.IO.File]::Exists($authFile)){
    Log-Message "Auth File doesn't exist '$authFile'" Debug

    $AuthInfo = New-Object PSObject
    $AuthInfo | Add-Member Noteproperty CustomerId ""
    $AuthInfo | Add-Member Noteproperty DomainID ""
    $AuthInfo | Add-Member Noteproperty ClientID ""
    $AuthInfo | Add-Member Noteproperty ClientSecret ""

    $AuthInfo.CustomerId = Read-Host -Prompt 'Customer Id'
    $AuthInfo.DomainID = Read-Host -Prompt 'Domain ID'
    $AuthInfo.ClientID = Read-Host -Prompt 'Client ID'
    $AuthInfo.ClientSecret = Read-Host -Prompt 'Client Secret'
} else {
    $AuthInfo = Get-Content $authFile | ConvertFrom-StringData
}

$CustomerID=$AuthInfo.CustomerId
$DomainID=$AuthInfo.DomainID
$ClientID=$AuthInfo.ClientID
$ClientSecret=$AuthInfo.ClientSecret

$CWPAuthenticationToken = CWPToken $CustomerID $DomainID $ClientID $ClientSecret
if ($CWPAuthenticationToken -eq $null)
{
    $message = "Issue retrieving Auth Token"
    Write-Host -ForegroundColor White -BackgroundColor Red $message
    Log-Message $message Debug
}
else
{
    $response = Get-AgentVersion "https://scwp.securitycloud.symantec.com" "all"
    $response
}

Log-Message "Script Ended" Debug

Exit

#endregion Execution