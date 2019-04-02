<#
.SYNOPSIS
  CWP Token

.DESCRIPTION
  Script to get an Auth Token from Symantec CWP (cloud Workload Protection).

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
  Creation Date:  01/04/2019
  Release Date:   dd/mm/yyyy
  Purpose/Change: Initial script release
  
.EXAMPLE
  Call '' to 
#>

#region Functions
#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Get-CWPToken
{
    <#
    .PARAMETER CustomerID
        The CustomerID from your Tenant
    .PARAMETER DomainID
        The DomainID from your Tenant
    .PARAMETER ClientID
        The ClientID from your Tenant
    .PARAMETER ClientSecret
        The ClientSecret from your Tenant
    
    .EXAMPLE
        Get-CWPToken "CustomerId" "DomainID" "ClientID" "ClientSecret"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$CustomerID,
        
        [Parameter(Mandatory=$true)]
        [string]$DomainID,

        [Parameter(Mandatory=$true)]
        [string]$ClientID,

        [Parameter(Mandatory=$true)]
        [string]$ClientSecret
    )

    Begin
    {}
    Process
    {
        try
        {
            if ([string]::IsNullOrEmpty($CustomerID) -Or [string]::IsNullOrEmpty($CustomerID) -Or [string]::IsNullOrEmpty($CustomerID) -Or [string]::IsNullOrEmpty($CustomerID))
            {
                $message = "One of the required parameters was null or empty."
                Write-Host -ForegroundColor White -BackgroundColor Red $message
                return $null
            }

            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
            #Define API Auth information
            $AuthUrl = 'https://scwp.securitycloud.symantec.com/dcs-service/dcscloud/v1/oauth/tokens'
            
            $AuthBody = @{
                'client_id' = $ClientID
                'client_secret' = $ClientSecret
            } | ConvertTo-Json
            
            $AuthHeaders = @{
                'content-type' = 'application/json'
                'x-epmp-customer-id' = $CustomerID
                'x-epmp-domain-id' = $DomainID
            }
            
            # Get Token
            $CWPToken = Invoke-RestMethod -Uri $Authurl -Method Post -Headers $Authheaders -Body $Authbody
            $CWPAuthToken = $CwpToken.token_type + " " + $CWPToken.access_token
            
            return $CWPAuthToken 
        }
        catch
        {
            $message = $Error.item(0)
            Write-Host -ForegroundColor White -BackgroundColor Red $message
            #return $message
        }
        finally
        {}
    }
    End
    {}
}

#endregion Functions