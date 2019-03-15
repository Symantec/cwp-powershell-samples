#Copyright 2017 Symantec Corporation. All righ1ts reserved.
#
#Script to get CWP asset agent installation status. CWP REST API keys are passed as commamnd line parameters
#Refer to CWP REST API at: https://apidocs.symantec.com/home/scwp#_fetch_assets_service
#Customer has to pass Customer ID, Domain ID, Client ID and Client Secret Key as arguments. The keys are available in CWP portal's Settings->API Key tab
#Usage: Usage: CWPAssets.ps1 -customerID ?? -DomainID ?? -ClientID ?? -ClientSecret ?? –InstanceID ??
#E.g:  .\CWPAssets.ps1 -customerID SEJ*CxAg -DomainID Dq*2w -ClientID O2ID.SE*xAg.Dq*B2w.t5*muo -ClientSecret qa*lud8 –InstanceID i-096ff50b85
#####################################################################################################

Param (
    [Parameter(Mandatory=$true)][string]$CustomerID,
    [Parameter(Mandatory=$true)][string]$DomainID,
    [Parameter(Mandatory=$true)][string]$ClientID,
    [Parameter(Mandatory=$true)][string]$ClientSecret,
    [Parameter(Mandatory=$true)][string]$InstanceID
 )

#Write-host $CustomerID $DomainID, $ClientID,$ClientSecret, $InstanceID

##Forces Tls1.2  -- but not needed for CWP
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Define API Auth information
$AuthUrl = 'https://scwp.securitycloud.symantec.com/dcs-service/dcscloud/v1/oauth/tokens'

$AuthBody = @{
  'client_id' = $ClientID
  'client_secret' = $Clientsecret
 } |ConvertTo-Json

$AuthHeaders = @{
  'content-type'= 'application/json'
  'x-epmp-customer-id'=$CustomerID
  'x-epmp-domain-id'=$DomainID}

#Authenticate & Get Token
try
{
    $CWPToken = Invoke-RestMethod -Uri $Authurl -Method Post -Headers $Authheaders -Body $Authbody
}
catch
{
  $ValueError = $_.Exception.Message
  Write-Host `n $ValueError 
  Break
}


#End of Authentication and Token creation code
#-------------------------------------------------------------------------------------------------------------

#Uncomment this code and specify log path for logging
#Start-Transcript -path c:\dnload\t.txt

try
{
  #Get assets
  $AssetURL = 'https://scwp.securitycloud.symantec.com/dcs-service/dcscloud/v1/ui/assets?'

  #Used for getting product information and version 
  #$AssetURL = $AssetURL +  "where=(cloud_platform in ['AWS'])&include=installed_products"
  $AssetURL = $AssetURL + "where=(instance_id='" + $InstanceID + "')&include=installed_products"
  #Write-host `n $AssetURL

  $AssetHeader = @{
  'content-type' = 'application/json'
  'Authorization' = $CwpToken.token_type +" " + $CWPToken.access_token
  'x-epmp-customer-id' = $CustomerID
  'x-epmp-domain-id' = $DomainID
  } 

  $CWPAssets = Invoke-RestMethod -Uri $AssetURL -Method GET -Headers $Assetheader #-body $AssetBody 
  #$CWPAssetso_JSON = $CWPAssets |ConvertTo-Json
  #write-host "Asset Info JSON:" $CWPAssets

  $InstanceID = $CWPAssets.results.instance_id
  $Name = $CWPAssets.results.name
  $ConnectionInfo = $CWPAssets.results.connectionInfo
  $securityAgent = $CWPAssets.results.security_agent
  $agentStatus = $CWPAssets.results.agent_installed.display_value
  Write-host "Instance ID:" $InstanceID
  Write-host "Instance Name:" $Name
  Write-host "Agent Status:" $agentStatus

  if ($ConnectionInfo) 
  {  
    Write-Host "Instance Connection Name:"  $ConnectionInfo.name
    if ($ConnectionInfo.awsAccoundID)
    {
        write-host "Instance Connection AWS Account Number:"  $ConnectionInfo.awsAccoundID
        #$ConnectionInfo_JSON = $ConnectionInfo |convertto-json
        #write-host "Connection Info JSON Object:" $ConnectionInfo_JSON
    }
  }
  else
  {
      Write-Host "Instance Connection Name: Private"
  }
  
 #Print Agent version info and AV Definitions Info
 #$securityAgent_JSON = $securityAgent |convertto-json
 #write-host "Agent Info JSON:" $securityAgent_JSON
 
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
    $AVContents = $securityAgent.contents

    #$AVContents_JSON = $AVContents |convertto-json
    #write-host "Agent AV Info JSON:" $AVContents_JSON

    if ($AVContents)
    {
      
      if ($AVContents."antivirus:version")
      {
        Write-Host "Instance Virus Definition Version: " $AVContents.'antivirus:version'
      }
    }
    #Print Support Agent Technologies   
    if ($securityAgent.supported_technologies)
    {
      Write-host "Agent Current Supported Protection Technologies: " $securityAgent.supported_technologies
    }
 }
 
 #write-host "----------------------------------------------------------"
 #stop-transcript
}
catch 
{
  $ValueError = $_.Exception.Message
  Write-Host `n $ValueError
}