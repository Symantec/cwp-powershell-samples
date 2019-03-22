# CWP Azure VM Extension installer PowerShell Script Help 

The script [InstallVMExtension.ps1](..\InstallVMExtension.ps1) will install the Cloud Workload Protection agent on supported Azure VM's.

## Prerequisites

To perform the following procedure, you must already have:
- Access to a valid Cloud Workload Protection account.
- Access to an Azure account that is connected with Cloud Workload Protection.
- See Setting up an Azure connection: http://help.symantec.com/cs/SCWP/SCWP/v113454583_v111037498/Setting-up-an-Azure-connection?locale=EN_US 
- Azure PowerShell with Administrator privilege.
- List of of the virtual machine where you want to install the agent via the CWP VM Extention
- PowerShell 3.0 or above and Azure Module for PowerShell should have been installed.
    - Install Azure Module: https://www.microsoft.com/web/handlers/webpi.ashx/getinstaller/WindowsAzurePowershellGet.3f.3f.3fnew.appids
    - .NET Framework 4.5 or above: https://www.microsoft.com/en-in/download/details.aspx?id=42642 
    - Upgrade PowerShell: https://www.microsoft.com/en-in/download/details.aspx?id=40855

This script [InstallVMExtension.ps1](..\InstallVMExtension.ps1) performs the following steps for each compatible virtual machine in your Azure environment where you want to install the Cloud Workload Protection agent.

To install the agent using PowerShell Script

- On the Cloud Workload Protection portal, go to `Settings > Downloads`.
- Under "Authentication Details", press "Show" and note down the following values:
    - `Customer ID`
    - `Domain ID`
    - `Customer Secret Key`
- On the Cloud Workload Protection portal, go to Settings > API Keys
- Press Show and note down the following values:
    - `Client ID`
    - `Client Secret Key`
- Start Azure PowerShell as an administrator.

Type the following commands on the Azure PowerShell window to run the script:

Sample 1 :

> `.\InstallVMExtension.ps1 -customerId <Customer ID>  -domainId <Domain ID> -secretKey <Customer Secret Key> -clientId <Client ID> -clientSecretKey <Client Secret Key>  -forceReboot yes -filePath .\config.txt`

- If Config file option is specified as in above usage, [config.txt](..\config.txt) files should contains below parameters
  - `subscriptionId=<Subscription-Id>`
  - `vmNames=AppServer, DBServer, WebServer, WindowsSQLIIS`

Sample 2 :

> `.\InstallVMExtension.ps1 -customerId <Customer ID>  -domainId <Domain ID> -secretKey <Customer Secret Key> -clientId <Client ID> -clientSecretKey <Client Secret Key> -forceReboot yes -vmNameList AppServer, DBServer, WebServer, WindowsSQLIIS -subscriptionId <Subscription-Id>`

E.g.:

> `InstallVMExtension.ps1 -customerId SEJxec*WP8STA8YCxAg -domainId Dqdf*64IITB2w  -secretKey 59df6c7*d780366919939daae800 -clientId O2ID*ru61uhhei0qsrc3k4p69 -clientSecretKey t6r4mc3pf*02huhg2srjhc5q -forceReboot yes -vmNameList DBServers, WebServers  -subscriptionId 1e6**00-3*19-4*3c-ba38-82f7***8b9d4`

- For Linux, enter Extension Name and Extension Type as SCWPAgentForLinux, and Version as 1.5.
- For Windows, enter Extension Name and Extension Type as SCWPAgentForWindows, and Version as 1.4.

If you specify forceReboot = yes, the command restarts the virtual machine after the agent is installed. Specify forceReboot = no to restart the virtual machine manually at your own convenience. You must restart the virtual machine for the agent installation to take effect. Default value set is yes. Until you restart the virtual machine, CWP console will show 'Agent Status' as 'Reboot Required'.

When you run the script, Azure PowerShell prompts you to log on to the Azure portal. Log on using with an Azure account that 'Owner' or "User access administrator" credentials.
The Azure PowerShell Script will display the status of the installation after it completes installation on all VM's.

After the agent is installed and the virtual machine is restarted, go to the "Instances" page of the Cloud Workload Protection portal. The 'Agent Status' for the virtual machine should show 'Installed'.

Below is the sample script run log:

```
PS .: InstallVMExtension.ps1 -customerId SEJxec*WP8STA8YCxAg -domainId Dqdf*64IITB2w  -secretKey 59df6c7*d780366919939daae800 -clientId O2ID*ru61uhhei0qsrc3k4p69 -clientSecretKey t6r4mc3pf*02huhg2srjhc5q -forceReboot yes -vmNameList DBServers, WebServers  -subscriptionId 1e6**00-3*19-4*3c-ba38-82f7***8b9d4
Subscription Id is 1e6**00-3*19-4*3c-ba38-82f7***8b9d4
VM-0 is CWPRHEL74-001
VM-1 is CWPUbuntu14-001
VM-2 is CWPWin2016-001
VM-3 is CWPWin2k12-001
Environment           : AzureCloud
Account               : <user>@symantec.com // Removed original values
TenantId              : <Tenant Id > // Removed original Tenant details
SubscriptionId        : xxxxxxxxxxxxxxxxxxxxxxxxxx  //Removed original Subscription details
SubscriptionName      : M***E1-N*2-E*G-PROD
CurrentStorageAccount : 
========================================================================
11/02/2018 - 10:19:58 - Install VM Extension Script Started.
========================================================================
-------------------------------------------------------------------
 ************ Customer data input ************ 
Customer Id                   : xxxxxxxxxxxxxxxxxxxxxxx
Domain Id                     : xxxxxxxxxxxxxxxxxxxxxxxxx
Secret Key                    : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Extension Publisher Name      : Symantec.CloudWorkloadProtection
Unix Extension Name           : SCWPAgentForLinux
Unix Extension Version        : 1.5
Unix Extension Type           : SCWPAgentForLinux
Windows Extension Name        : SCWPAgentForWindows
Windows Extension Version     : 1.4
Windows Extension Type        : SCWPAgentForWindows
Force Reboot Option           : yes
-------------------------------------------------------------------
PowerState     Id ExtensionInstal ResourceGroup   Location  Name  CWPExtensionTy CWPExtensionNa CWPExtensionVe OSPlatform    
----------                   -- --------------- -------------   --------       ----           -------------- -------------- -------------- ----------    
Running                       1 False           CWPINSTALLVM... eastus         CWPUbuntu14... SCWPAgentFo... SCWPAgentFo... 1.5            Linux         
Deallocated                   2 False           OELTESTING      eastus         SupritOEL73DND SCWPAgentFo... SCWPAgentFo... 1.5            Linux         
Deallocated                   3 False           OELTESTING      eastus         RajOra69DND SCWPAgentFo... SCWPAgentFo... 1.5            Linux         
Deallocated                   4 False           AGENTTESTHU     westus         OELRHEL74HU    SCWPAgentFo... SCWPAgentFo... 1.5            Linux         
Deallocated                   5 False           AGENTTESTHU     westus         OELRHEL74HU2   SCWPAgentFo... SCWPAgentFo... 1.5            Linux         
Running                       6 False           CWPINSTALLVM... southeastasia  CWPRHEL74-001  SCWPAgentFo... SCWPAgentFo... 1.5            Linux         
Running                       7 False           CWPINSTALLVM... southeastasia  CWPWin2k12-001 SCWPAgentFo... SCWPAgentFo... 1.4            Windows       
Running                       8 False           CWPINSTALLVM... SouthIndia     CWPWin2016-001 SCWPAgentFo... SCWPAgentFo... 1.4            Windows       
Deallocated                   9 False           AGENTTESTHU     westus2        CentOS67HU     SCWPAgentFo... SCWPAgentFo... 1.5            Linux         

-------------------------------------------------------------------
              VM's Selected to install extensions are              
-------------------------------------------------------------------
 

CWPExtensionVersi ExtensionInstall PowerState       CWPExtensionType ResourceGroupNam Name             Location         CWPExtensionName OSPlatform      
on                Status                                             e                                                                                   
----------------- ---------------- ----------       ---------------- ---------------- ----             --------         ---------------- ----------      
1.5               False            Running          SCWPAgentForL... CWPINSTALLVME... CWPUbuntu14-001  eastus           SCWPAgentForL... Linux           
1.5               False            Running          SCWPAgentForL... CWPINSTALLVME... CWPRHEL74-001    southeastasia    SCWPAgentForL... Linux           
1.4               False            Running          SCWPAgentForW... CWPINSTALLVME... CWPWin2k12-001   southeastasia    SCWPAgentForW... Windows         
1.4               False            Running          SCWPAgentForW... CWPINSTALLVME... CWPWin2016-001   SouthIndia       SCWPAgentForW... Windows         

INFO: CWPUbuntu14-001: Is running a Linux OS, extension.
-------------------------------------------------------------------
Installing VM Extension on  Virtual Machine [ CWPUbuntu14-001 ]           
-------------------------------------------------------------------
 
SUCCESS: CWPUbuntu14-001: Extension installed successfully
INFO: CWPRHEL74-001: Is running a Linux OS, extension.
-------------------------------------------------------------------
Installing VM Extension on  Virtual Machine [ CWPRHEL74-001 ]           
-------------------------------------------------------------------
 
SUCCESS: CWPRHEL74-001: Extension installed successfully
INFO: CWPWin2k12-001: Is running a Windows OS, extension.
-------------------------------------------------------------------
Installing VM Extension on  Virtual Machine [ CWPWin2k12-001 ]           
-------------------------------------------------------------------
 
SUCCESS: CWPWin2k12-001: Extension installed successfully
INFO: CWPWin2016-001: Is running a Windows OS, extension.
-------------------------------------------------------------------
Installing VM Extension on  Virtual Machine [ CWPWin2016-001 ]           
-------------------------------------------------------------------
SUCCESS: CWPWin2016-001: Extension installed successfully
========================================================================
Extension Symantec.CloudWorkloadProtection - Installation Results
Installation Successful         : 4
Already Installed               : 0
Installation Failed             : 0
VMs Not Running                 : 0
Extension Not Compatible with OS: 0
Total VMs Processed             : 
========================================================================
                VM Extension Install Status is as below .                 
========================================================================
CWPExtensionVer ExtensionInstal PowerState      CWPExtensionTyp ResourceGroupN Name           Location       CWPExtensionNa Reason         OSPlatform   
sion            lStatus                         e               ame                                          me                                          
--------------- --------------- ----------      --------------- -------------- ----           --------       -------------- ------         ----------    
1.5             SUCCESS         Running         SCWPAgentFor... CWPINSTALLV... CWPUbuntu14... eastus         SCWPAgentFo... Successfull... Linux         
1.5             SUCCESS         Running         SCWPAgentFor... CWPINSTALLV... CWPRHEL74-001  southeastasia  SCWPAgentFo... Successfull... Linux         
1.4             SUCCESS         Running         SCWPAgentFor... CWPINSTALLV... CWPWin2k12-001 southeastasia  SCWPAgentFo... Successfull... Windows       
1.4             SUCCESS         Running         SCWPAgentFor... CWPINSTALLV... CWPWin2016-001 SouthIndia     SCWPAgentFo... Successfull... Windows       

========================================================================

11/02/2018 - 10:41:05 - Install VM Extension Script Complete.

========================================================================
```