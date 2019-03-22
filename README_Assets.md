# CWP PowerShell Samples

Symantec CWP PowerShell script samples for returning asset information from [CWP](https://www.symantec.com/products/cloud-workload-protection).

For More information go to: https://apidocs.symantec.com/home/scwp

Code Files:

[CWPAssets.ps1](CWPAssets.ps1)

This Powershell script returns the asset infromation 

The location of the [CWPAuth.ini](CWPAuth.ini) file will need to be updated with the location of the ini file. By default it looks in `C:\CWPPowershell\CWPAuth.ini`

[CWPAuth.ini](CWPAuth.ini)

This file needs to be updated with the client information. This information can be retrieved from your CWP console by going to `Settings - API Keys` and clicking the "Show" button.
    
[cwpasset_agent_status.ps1](cwpasset_agent_status.ps1)

Script to get CWP asset agent installation status. CWP REST API keys are passed as commamnd line parameters

Usage:
> `CWPAssets.ps1 -customerID ?? -DomainID ?? -ClientID ?? -ClientSecret ?? –InstanceID ??`

E.g:
> `.\CWPAssets.ps1 -customerID SEJ*CxAg -DomainID Dq*2w -ClientID O2ID.SE*xAg.Dq*B2w.t5*muo -ClientSecret qa*lud8 –InstanceID i-096ff50b85`
