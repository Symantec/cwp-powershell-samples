#Get User information from CWPAuth.ini file.  The API Information can be found for your account from the CWP Console under
#  Setting - API Keys  
#-------------------------------------------------------------------------------------------------------------
#Begin Get CWP Authentication Token
$AuthInfo = get-content 'C:\CWPPowershell\CWPAuth.ini' |ConvertFrom-StringData

    $CustomerID=$AuthInfo.CustomerId
    $DomainID=$AuthInfo.DomainID
    $ClientID=$AuthInfo.ClientID
    $ClientSecret=$AuthInfo.ClientSecret

    #Function to authenticate and return token from the CWP Server
function CWPToken ([string]$CustomerID,[string]$DomainID,[string]$ClientID,[string]$ClientSecret)
    {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    #Define API Auth information
    $AuthUrl = 'https://scwp.securitycloud.symantec.com/dcs-service/dcscloud/v1/oauth/tokens'
    #$CustomerInfo = Get-CustInfo
    #$customerinfo.$customerid
    
    $AuthBody = @{
      'client_id' = $ClientID
      'client_secret' = $ClientSecret
     } |ConvertTo-Json
    
    $AuthHeaders = @{
      'content-type'= 'application/json'
      'x-epmp-customer-id'=$CustomerID
      'x-epmp-domain-id'=$DomainID}
    
    # Get Token
    $CWPToken = Invoke-RestMethod -Uri $Authurl -Method Post -Headers $Authheaders -Body $Authbody
    $CWPAuthToken = $CwpToken.token_type +" " + $CWPToken.access_token
    return $CWPAuthToken 
    #End of Authentication and Token creation code
    
    }
   
#End of Authentication and Token creation code
#-------------------------------------------------------------------------------------------------------------

#Set output of Function to a variable
$CWPAuthenticationToken= CWPToken $CustomerID $DomainID $ClientID $ClientSecret

#Get assets
$AssetURL = 'https://scwp.securitycloud.symantec.com/dcs-service/dcscloud/v1/ui/assets?'

#Used for getting product information and version 
$AssetURL = $AssetURL +  "where=(cloud_platform in ['AWS'])&include=installed_products"

$AssetHeader = @{
  'content-type' = 'application/json'
  'Authorization' =  $CWPAuthenticationToken
  'x-epmp-customer-id' = $CustomerID
  'x-epmp-domain-id' = $DomainID
} 

# $AssetBody = @{'limit'=100
#                 'offset'=0 
#                 'where'=''
#                 'include'=''
#               }

$CWPAssets = Invoke-RestMethod -Uri $AssetURL -Method GET -Headers $Assetheader #-body $AssetBody 

for ($i = 0; $i -lt $cwpassets.results.Count; $i++) 
{
  $InstanceID = $CWPAssets.results.instance_id[$i]
  $Name = $CWPAssets.results.name[$i]
  $ConnectionInfo = $CWPAssets.results.connectionInfo[$i]
  $securityAgent = $CWPAssets.results.security_agent[$i]
  Write-host "Instance ID:  " $InstanceID
  Write-host "Instance Name:  " $Name

  if ($ConnectionInfo) 
  {  
    Write-Host "Instance Connection Name:    "  $ConnectionInfo.name `n
    if ($ConnectionInfo.awsAccoundID)
      {
        write-host "Instance Connection AWS Account Number:   "  $ConnectionInfo.awsAccoundID `n
        $ConnectionInfo_JSON = $ConnectionInfo |convertto-json
        write-host "Connection Info JSON Object: " $ConnectionInfo_JSON
      }
  else{
      Write-Host "Instance is private with no connection" `n
      }
  }
#Print Agent version info and AV Definitions Info
 if ($securityAgent)
 {
   $SecurityAgentProps = $securityAgent.props
 
    if($SecurityAgentProps)
    {
      if($SecurityAgentProps.cwp_agent_product_version)
      {Write-host "Instance Hardening Agent Version:   " $SecurityAgentProps.cwp_agent_product_version}
      if($SecurityAgentProps.cwp_av_agent_product_version)
      {write-host "Instance AntiVirus Agent Version:  " $SecurityAgentProps.cwp_av_agent_product_version}
    }
    $AVContents = $SecurityAgent.$Contents
    if ($AVContents)
    {
      if ($AVContents.'antivirus:version')
      {
        Write-Host "Instance Virus Definition Version: " $Contents.'antivirus:version'
      }
    }
 #Print Support Agent Technologies   
  if ($securityAgent.supported_technologies)
  {
    Write-host `n "Agent Current Supported Protection Technologies: " $securityAgent.supported_technologies
  }
 #Dump the entire CWP security agent JSON
 $SecurityAgent_JSON = $securityAgent[$i] |convertto-json
 Write-Host `n"Printing Entire SecurityAgent Object Json:  "  $SecurityAgent_JSON 
}
#Print tages - CWP or AWS/Azure
  if ($CWPAssets.results.included_dcs_tags)
  {
    $InstanceTags = $CWPAssets.results.included_dcs_tags[$i] |convertto-json
    Write-Host "Printing Tags Json: "$InstanceTags
  }
#Enumerate all discovered applications and Vulnerabilities
 $InstalledProducts = $CWPAssets.results[$i]
 for ($p = 0; $p -lt $InstalledProducts.included_installed_products.count; $p++)
  {
    $InstallProd_Name = $InstalledProducts.included_installed_products.name[$p]
    if ($InstallProd_Name -ne 'DCS.Cloud Agent')
    {
      Write-Host `n "Application Name:  " $InstallProd_Name
      $Vulnerabilities = $InstalledProducts.included_installed_products.is_potential_risk
      if ($Vulnerabilities)
      {
        Write-Host "Vulnerabilities:  " $Vulnerabilities.count
      }
    }
  }
  write-host "----------------------------------------------------------"
}
