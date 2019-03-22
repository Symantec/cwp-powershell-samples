# CWP Powershell Samples

[![Symantec](https://img.shields.io/badge/tag-symantec-yellow.svg)](https://www.symantec.com/)
[![CWP](https://img.shields.io/badge/tag-cwp-yellow.svg)](https://www.symantec.com/products/cloud-workload-protection)
[![PowerShell](https://img.shields.io/badge/language-powershell-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
|
[![GitHub contributors](https://img.shields.io/github/contributors/Symantec/cwp-powershell-samples.svg)](https://GitHub.com/Symantec/cwp-powershell-samples/graphs/contributors/)
|
[![GitHub issues](https://img.shields.io/github/issues/Symantec/cwp-powershell-samples.svg)](https://GitHub.com/Symantec/cwp-powershell-samples/issues/)
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/Symantec/cwp-powershell-samples.svg)](https://GitHub.com/Symantec/cwp-powershell-samples/issues?q=is%3Aissue+is%3Aclosed)
[![GitHub pull-requests](https://img.shields.io/github/issues-pr/Symantec/cwp-powershell-samples.svg)](https://GitHub.com/Symantec/cwp-powershell-samples/pull/)


Symantec CWP PowerShell script samples for automating deployment of CWP agent on Azure Virtual machines using Azure VmExtension

For More information go to: https://help.symantec.com/cs/SCWP/SCWP/v123139765_v111037498/Installing-Cloud-Workload-Protection-agents-by-using-PowerShell-commands?locale=EN_US

-----------------------------------------------------------------------------------------------------------------------

- [CWP Powershell Samples](#cwp-powershell-samples)
  - [Docs](#docs)
  - [Setup](#setup)
  - [Install VM Extension](#install-vm-extension)
  - [CWP Assets](#cwp-assets)
  - [CWPAsset Agent Status](#cwpasset-agent-status)

-----------------------------------------------------------------------------------------------------------------------

## Docs

See
- [CWP Installer Script Help.docx](docs/CWP%20Installer%20Script%20Help.docx) or [CWP Installer Script Help](docs/CWPInstallerScriptHelp.md)

-----------------------------------------------------------------------------------------------------------------------

## Setup

Refer to Symantec CWP API documentation at: https://apidocs.symantec.com/home/scwp

Before you get started you need a Symantec Cloud Workload Protection Account.
If you do not have one sign up for a trial account using this link, select the 'Cloud Workload Protection' check box: https://securitycloud.symantec.com/cc/?CID=70138000001QHo5&pr_id=F979E61C-A412-4A58-8879-B83E25B7327F#/onboard

You can also buy Cloud Workload protection from Amazon AWS Market Place that also includes free usage.
Click this link: https://aws.amazon.com/marketplace/pp/B0722D4QRN

After you have activated your account, completed AWS, Azure or Google Cloud Connection; deployed CWP agent on our cloud instances, you are ready to start using these samples

First step is to Create API access keys.
After login to CWP console, go to 'Settings' page and click on 'API Keys' tab

Update the [CWPAuth.ini](CWPAuth.ini) to contain your keys.

```
CustomerID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
DomainID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ClientID=xxxx.xxxxxxxxxxxxxx-xxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxx
ClientSecret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

-----------------------------------------------------------------------------------------------------------------------
**Code Files**

-----------------------------------------------------------------------------------------------------------------------
## Install VM Extension
[InstallVMExtension.ps1](InstallVMExtension.ps1)

This Powershell script helps in automating deployment of Symantec CWP VM Extension 'Symantec.CloudWorkloadProtection.SCWPAgentForWindows' or 'Symantec.CloudWorkloadProtection.SCWPAgentForLinux' Execution Usage :

Sample 1 : 
> `.\InstallVMExtension.ps1 -customerId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -domainId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -secretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientId O2ID.xxxxxxxxxxxxxxxxxxx.e3EAztazTs6iWwYEBoZ-NQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientSecretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -filePath .\config.txt`

If Config file option is specified as in above usage, [config.txt](config.txt) files should contains below parameters

```
subscriptionId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
vmNames=AppServer, DBServer, WebServer, WindowsSQLIIS
```

Sample 2 :
> `.\InstallVMExtension.ps1 -customerId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -domainId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -secretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -forceReboot yes -vmNameList AppServer, DBServer, WebServer, WindowsSQLIIS -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -clientId O2ID.xxxxxxxxxxxxxxxxxxx.e3EAztazTs6iWwYEBoZ-NQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientSecretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

-----------------------------------------------------------------------------------------------------------------------
## CWP Assets
[CWPAssets.ps1](CWPAssets.ps1)

See [README_Assets.md](README_Assets.md) for more info.

-----------------------------------------------------------------------------------------------------------------------
## CWPAsset Agent Status
[cwpasset_agent_status.ps1](cwpasset_agent_status.ps1)

Script to get CWP asset agent installation status. CWP REST API keys are passed as commamnd line parameters

Refer to CWP REST API at: https://apidocs.symantec.com/home/scwp#_fetch_assets_service

Customer has to pass `Customer ID`, `Domain ID`, `Client ID` and `Client Secret Key` as arguments. The keys are available in CWP portal's `Settings->API Key` tab

Usage: 
> `cwpasset_agent_status.ps1 -customerID ?? -DomainID ?? -ClientID ?? -ClientSecret ?? –InstanceID ??`

E.g: 
`cwpasset_agent_status.ps1 -customerID SEJ*CxAg -DomainID Dq*2w -ClientID O2ID.SE*xAg.Dq*B2w.t5*muo -ClientSecret qa*lud8 –InstanceID i-096ff50b85`


-----------------------------------------------------------------------------------------------------------------------
