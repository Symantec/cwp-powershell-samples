# cwp-powershell-samples
Symantec CWP powershell script samples for automating deployment of CWP agent on Azure Virtual machines using Azure VmExtension

For More information go to: https://help.symantec.com/cs/SCWP/SCWP/v123139765_v111037498/Installing-Cloud-Workload-Protection-agents-by-using-PowerShell-commands?locale=EN_US

Code Files

InstallVMExtension.ps1

This Powershell script helps in automating deployment of Symantec CWP VM Extension 'Symantec.CloudWorkloadProtection.SCWPAgentForWindows' or 'Symantec.CloudWorkloadProtection.SCWPAgentForLinux' Execution Usage :

Sample 1 : .\InstallVMExtension.ps1 -customerId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -domainId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -secretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientId O2ID.xxxxxxxxxxxxxxxxxxx.e3EAztazTs6iWwYEBoZ-NQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientSecretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -filePath .\config.txt

If Config file option is specified as in above usage, config.tx files should contains below parameters

subscriptionId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

vmNames=AppServer, DBServer, WebServer, WindowsSQLIIS
