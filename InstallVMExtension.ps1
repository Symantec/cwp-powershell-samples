# Execution Command :
# Sample 1 : .\InstallVMExtension.ps1 -customerId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -domainId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -secretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientId O2ID.xxxxxxxxxxxxxxxxxxx.e3EAztazTs6iWwYEBoZ-NQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientSecretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -filePath .\config.txt
# If Config file option is specified as in above usage, config.tx files should contains below parameters
# subscriptionId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# vmNames=AppServer, DBServer, WebServer, WindowsSQLIIS
# Sample 2 : .\InstallVMExtension.ps1 -customerId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -domainId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -secretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -forceReboot yes -vmNameList AppServer, DBServer, WebServer, WindowsSQLIIS -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -clientId O2ID.xxxxxxxxxxxxxxxxxxx.e3EAztazTs6iWwYEBoZ-NQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx -clientSecretKey xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# For more information on Azure VM Extension go to: https://help.symantec.com/cs/SCWP/SCWP/v123139765_v111037498/Installing-Cloud-Workload-Protection-agents-by-using-PowerShell-commands?locale=EN_US
#------------------------------------------------------------------------------------------------------------------------------------------------
param (
    [string]$customerId = $(throw "-customerId is required."), 
    [string]$domainId = $(throw "-domainId is required."), 
    [string]$secretKey = $(throw "-secretKey is required.") ,
    [string]$clientId = $(throw "-clientId is required.") ,
    [string]$clientSecretKey = $(throw "-clientSecretKey is required.") ,
    [string]$forceReboot = "yes",
    [CmdletBinding(DefaultParameterSetName='ByvmList')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ByvmList')]
        [string[]]$vmNameList,
        [Parameter(ParameterSetName='ByvmList',Mandatory=$true)][string]$subscriptionId,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByfilePath')]
        [System.String]$filePath
)

cls

$i = 0
if($PSBoundParameters.ContainsKey('vmNameList')){
    echo "Subscription Id is $subscriptionId"
    echo "VM's on which CWP Extension installed are as below,"
    foreach ($arg in $vmNameList) 
    { echo "VM-$i is $arg"; $i++ }
}

if($PSBoundParameters.ContainsKey('filePath')){
    echo "File path parameter is set to $filePath"
    $values = [pscustomobject](Get-Content $filePath -Raw | ConvertFrom-StringData)
    $vmNameList = $values.vmNames -split ','
    $subscriptionId = $values.subscriptionId
    
    if(!$vmNameList){
        Write-Host "VM Name List is not set in the config file $filePath"
        exit
    }
    if(!$subscriptionId){
        Write-Host "Subscription Name  is not set in the config file $filePath"
        exit 
    }
    echo "Subscription Name is $subscriptionId"
    echo "VM's on which CWP Extension installed are as below,"
    foreach ($arg in $vmNameList) 
    {  echo "VM-$i is $arg"; $i++ }
}


#Install-Module AzureRM -Force
#Import-Module AzureRM
if ( ($PSVersionTable.PSVersion -ge '3.0') -and ($PSVersionTable.CLRVersion -ge '4.0.30319.34000') -and (Get-Module -ListAvailable AzureRM.Profile) -and (Get-Module -ListAvailable AzureRM.Resources)) 
{
    
    #Login-AzureRmAccount >$null
    Login-AzureRmAccount -ErrorAction Stop
    [string]$DateTimeNow = get-date -Format "dd/MM/yyyy - HH:mm:ss"
    Write-Host "`n========================================================================`n"
    Write-Host "$($DateTimeNow) - Install VM Extension Script Started.`n"
    Write-Host "========================================================================`n"

    # Setup counters for Extension installation results
    [double]$Global:SuccessCount = 0
    [double]$Global:FailedCount = 0
    [double]$Global:AlreadyInstalledCount = 0
    [double]$Global:VMsNotRunningCount = 0
    [double]$Global:OSNotCompatibleCount = 0


    #CWP VM Extension inputs - <Do not change unless CWP VM Extension name or version has changed>
    $publisher            = "Symantec.CloudWorkloadProtection"
    $winExtensionName     = "SCWPAgentForWindows"
    $winExtensionType     = "SCWPAgentForWindows"
    $winExtensionVersion  = "1.4"
    $unixExtensionName    = "SCWPAgentForLinux"
    $unixExtensionType    = "SCWPAgentForLinux"
    $unixExtensionVersion = "1.5"


    function Create-AesManagedObject($key, $IV) 
    {
        $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
        $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
        $aesManaged.BlockSize = 128
        $aesManaged.KeySize = 256

        if ($IV) 
        {
            if ($IV.getType().Name -eq "String") {
                $aesManaged.IV = [System.Convert]::FromBase64String($IV)
            }
            else {
            $aesManaged.IV = $IV
            }
        }
         if ($key) 
         {
            if ($key.getType().Name -eq "String") 
            {
                $aesManaged.Key = [System.Convert]::FromBase64String($key)
            }else 
            {
                $aesManaged.Key = $key
            }
         }
         $aesManaged
    }#Create-AesManagedObject

    function Create-AesKey() 
    {
        $aesManaged = Create-AesManagedObject 
        $aesManaged.GenerateKey()
        [System.Convert]::ToBase64String($aesManaged.Key)
    }

    function ClearBk
    {
        while(
            $Host.UI.RawUI.KeyAvailable){$Host.UI.RawUI.ReadKey() | Out-Null
        }
    }

    #Create the 44-character key value
    $keyValue = Create-AesKey
    $startDate = Get-Date

    
   
    Set-AzureRmContext -SubscriptionId $subscriptionId >$null
    

    Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host " ************ Customer data input ************ " -ForegroundColor Cyan
    Write-Host "Azure Subscription Id         : $subscriptionId" -ForegroundColor Cyan
    Write-Host "Customer Id                   : $customerId" -ForegroundColor Cyan 
    Write-Host "Domain Id                     : $domainId" -ForegroundColor Cyan 
    Write-Host "Secret Key                    : $secretKey" -ForegroundColor Cyan
    Write-Host "Extension Publisher Name      : $publisher" -ForegroundColor Cyan
    Write-Host "Unix Extension Name           : $unixExtensionName" -ForegroundColor Cyan
    Write-Host "Unix Extension Version        : $unixExtensionVersion" -ForegroundColor Cyan
    Write-Host "Unix Extension Type           : $unixExtensionType" -ForegroundColor Cyan
    Write-Host "Windows Extension Name        : $winExtensionName" -ForegroundColor Cyan
    Write-Host "Windows Extension Version     : $winExtensionVersion" -ForegroundColor Cyan
    Write-Host "Windows Extension Type        : $winExtensionType" -ForegroundColor Cyan
    Write-Host "Force Reboot Option           : $forceReboot" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
    " "

    $settings = @{"customerId"= $customerId; "domainId"= $domainId; "forceReboot"= $forceReboot;"clientId"=$clientId};
    $protectedSettings = @{"customerSecretKey"= $secretKey;"clientSecretKey"=$clientSecretKey};
   
           
    ($rmvms=Get-AzurermVM) > 0
    $vmarray = @()
    $i=1;
        
    # Add info about VM's from the Resource Manager to the array
    foreach ($vm in $rmvms)
    {    
        # Get status (does not seem to be a property of $vm, so need to call Get-AzurevmVM for each rmVM)
        $vmstatus = Get-AzurermVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Status 
        $status = (get-culture).TextInfo.ToTitleCase(($vmstatus.statuses)[1].code.split("/")[1]);
        $OS = "";
        if($vm.OSProfile.WindowsConfiguration) 
        {
            # VM is running Linux distro and $VMExtensionLinuxCompatible = $false
            # Write-Host "INFO: $($vm.Name): Is running a Windows OS, extension."
            
            $OS = "Windows";
            $extensionName = $winExtensionName
            $extensionType = $winExtensionType
            $version = $winExtensionVersion
        }
        if($vm.OSProfile.LinuxConfiguration) 
        {
            # VM is running Linux distro and $VMExtensionLinuxCompatible = $false
            # Write-Host "INFO: $($vm.Name): Is running a Linux OS, extension."
            $OS = "Linux";
            $extensionName = $unixExtensionName
            $extensionType = $unixExtensionType
            $version = $unixExtensionVersion
        }

        if(($vm.Extensions.count -eq 0) -or (!(Split-Path -Leaf $vm.Extensions.id).Contains($extensionName))){
            $extensionInstalledStatus = "False"
        }else{
            $extensionInstalledStatus = "True"
        }
        # Add values to the array:

        $vmarray += New-Object PSObject -Property @{
                Id=$i++;
                OSPlatform=$OS;
                Location=$vm.Location;
                ResourceGroup=$vm.ResourceGroupName;
                Subscription=$subName;
                AzureMode="Resource_Manager";
                Name=$vm.Name; 
                PowerState=(get-culture).TextInfo.ToTitleCase(($vmstatus.statuses)[1].code.split("/")[1]);
                Size=$vm.HardwareProfile.VmSize;
                ExtensionInstallStatus=$extensionInstalledStatus;
                CWPExtensionName=$extensionName;
                CWPExtensionType=$extensionType;
                CWPExtensionVersion=$version
            }
        
        
    }
    $vmarray | ft

    $vmNameList | ft

    $vmToInstallExtension = @()

    
        foreach($vma in $vmarray){
            foreach($vmName in $vmNameList){
                if($vma.Name -eq $vmName){
                    write-output "VM Name is  $vmName"
                    $vmToInstallExtension += New-Object PSObject -Property @{
                        Name=$vma.Name;
                        Location=$vma.Location;
                        ResourceGroupName=$vma.ResourceGroup;
                        PowerState=$vma.PowerState;
                        OSPlatform=$vma.OSPlatform;
                        ExtensionInstallStatus=$vma.ExtensionInstallStatus;
                        CWPExtensionName=$vma.CWPExtensionName;
                        CWPExtensionType=$vma.CWPExtensionType;
                        CWPExtensionVersion=$vma.CWPExtensionVersion
                    }
                }
            }
        }
    

    Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "              VM's Selected to install extensions are              " -ForegroundColor Blue 
    Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
    " "
    $vmToInstallExtension | ft

    $vmInstallExtensionResult = @()

    foreach ($vm in $vmToInstallExtension)
    {    
        $status = $vm.PowerState;
        
        
        if($vm.OSPlatform -eq "Windows") 
        {
            # VM is running Linux distro and $VMExtensionLinuxCompatible = $false
            Write-Host "INFO: $($vm.Name): Is running a Windows OS, extension."
            $extensionName = $winExtensionName
            $extensionType = $winExtensionType
            $version = $winExtensionVersion
        }
        if($vm.OSPlatform -eq "Linux") 
        {
            # VM is running Linux distro and $VMExtensionLinuxCompatible = $false
            Write-Host "INFO: $($vm.Name): Is running a Linux OS, extension."
            $extensionName = $unixExtensionName
            $extensionType = $unixExtensionType
            $version = $unixExtensionVersion
        }

        if($status -ne 'Running'){
            Write-Host "Can not install VM Extension on  Virtual Machine since it is not in Running state." -ForegroundColor Red 
            $Global:VMsNotRunningCount++
            continue;
        }
        
        ClearBk

        Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
        Write-Host "Installing VM Extension on  Virtual Machine ["$vm.Name"]           " -ForegroundColor Cyan 
        Write-Host "-------------------------------------------------------------------" -ForegroundColor Gray
        " "
            
        if($vm.ExtensionInstallStatus -eq "False") {

            $ExtensionInstallResult = Set-AzureRmVMExtension -VMName $vm.Name -ResourceGroupName $vm.ResourceGroupName -Publisher $publisher -ExtensionName $extensionName -Location $vm.Location -ExtensionType $extensionType -Version $version -Settings $settings -ProtectedSettings $protectedSettings
                
            if($ExtensionInstallResult.IsSuccessStatusCode -eq $true) {
                # Installation Succeeded
                Write-Host "SUCCESS: " -ForegroundColor Green -nonewline; `
                Write-Host "$($vm.Name): Extension installed successfully"
                $Global:SuccessCount++
                $vmInstallExtensionResult += New-Object PSObject -Property @{
                    Name=$vm.Name;
                    Location=$vm.Location;
                    ResourceGroupName=$vm.ResourceGroupName;
                    PowerState=$vm.PowerState;
                    OSPlatform=$vm.OSPlatform;
                    ExtensionInstallStatus="SUCCESS";
                    Reason="Successfully Installed";
                    CWPExtensionName=$vm.CWPExtensionName;
                    CWPExtensionType=$vm.CWPExtensionType;
                    CWPExtensionVersion=$vm.CWPExtensionVersion
                }
            } else {
                # Installation Failed
                Write-Host "ERROR: " -ForegroundColor Red -nonewline; `
                Write-Host "$($vm.Name): Failed - Status Code: $($ExtensionInstallResult.StatusCode)"
                $Global:FailedCount++

                $vmInstallExtensionResult += New-Object PSObject -Property @{
                    Name=$vm.Name;
                    Location=$vm.Location;
                    ResourceGroupName=$vm.ResourceGroupName;
                    PowerState=$vm.PowerState;
                    OSPlatform=$vm.OSPlatform;
                    ExtensionInstallStatus="FAILED";
                    Reason="Status Code: $($ExtensionInstallResult.StatusCode)";
                    CWPExtensionName=$vm.CWPExtensionName;
                    CWPExtensionType=$vm.CWPExtensionType;
                    CWPVersion=$vm.CWPExtensionVersion
                }
            }
        } else {
            # VM already has the Extension installed.
            Write-Host "INFO: $($vm.Name): Already has the $($extensionName) Extension Installed"
            $Global:AlreadyInstalledCount++
            $vmInstallExtensionResult += New-Object PSObject -Property @{
                    Name=$vm.Name;
                    Location=$vm.Location;
                    ResourceGroupName=$vm.ResourceGroupName;
                    PowerState=$vm.PowerState;
                    OSPlatform=$vm.OSPlatform;
                    ExtensionInstallStatus="SUCCESS";
                    Reason="Already Installed";
                    CWPExtensionName=$vm.CWPExtensionName;
                    CWPExtensionType=$vm.CWPExtensionType;
                    CWPVersion=$vm.CWPExtensionVersion
                }
        }
            

        
    }



    # Output Extension Installation Results
    Write-Host "`n"
    Write-Host "========================================================================"
    Write-Host "`tExtension $($publisher) - Installation Results`n"
    Write-Host "Installation Successful         : $($Global:SuccessCount)"
    Write-Host "Already Installed               : $($Global:AlreadyInstalledCount)"
    Write-Host "Installation Failed             : $($Global:FailedCount)"
    Write-Host "VMs Not Running                 : $($Global:VMsNotRunningCount)"
    Write-Host "Extension Not Compatible with OS: $($Global:OSNotCompatibleCount)`n"
    Write-Host "Total VMs Processed             : $($TotalVMsProcessed)"
    Write-Host "========================================================================`n`n"
    

    Write-Host "`n========================================================================`n" -ForegroundColor Gray
    Write-Host "                VM Extension Install Status is as below .                 `n" -ForegroundColor Red
    Write-Host "========================================================================`n"  -ForegroundColor Gray
    

    $vmInstallExtensionResult | ft
    
    
    [string]$DateTimeNow = get-date -Format "dd/MM/yyyy - HH:mm:ss"
    Write-Host "`n========================================================================`n"
    Write-Host "$($DateTimeNow) - Install VM Extension Script Complete.`n"
    Write-Host "========================================================================`n"
    


}# IF Condition
else {
 
    Write-Host "Checking the prerequisites..." -ForegroundColor Red -BackgroundColor black

    if ( $PSVersionTable.PSVersion -lt '3.0' )
    {
        " "
        Write-Host "PowerShell version check - in progress.. " -ForegroundColor Gray
        "Please upgrade PowerShell version to 3.0 or later."
        Write-Host "( https://www.microsoft.com/en-in/download/details.aspx?id=40855 ) " -ForegroundColor Yellow
    } else 
    {
        " "
        Write-Host "PowerShell version check - in progress.. " -ForegroundColor Gray
        Write-Host "Powershell version check - Successful! " -ForegroundColor Green
    }
 
    if ( $PSVersionTable.CLRVersion -lt '4.0.30319.34000' )
    {
        " "
        Write-Host ".Net Framework version check - in progress.. " -ForegroundColor Gray
        "Please upgrade .Net Framework version to 4.5.2 (CLRVersion) or later." 
        Write-Host "( https://www.microsoft.com/en-in/download/details.aspx?id=42642 ) " -ForegroundColor Yellow
        " "
        Write-Host "Azure PowerShell module check - in progress.. " -ForegroundColor Gray
    } else 
    {
        " "
        Write-Host ".Net Framework version check - in progress.. " -ForegroundColor Gray
        Write-Host "CLR version(.Net Framework) check - Successful! " -ForegroundColor Green
        " "
        Write-Host "Azure PowerShell module check - in progress.. " -ForegroundColor Gray

    }

    if ( (Get-Module -ListAvailable AzureRM.Profile) -and (Get-Module -ListAvailable AzureRM.Resources) )

    {
 
        Write-Host "Azure PowerShell module check - Successful! " -ForegroundColor Green
        " "

    } else 
    {
        "Please install the Azure PowerShell module."
        Write-Host "( https://www.microsoft.com/web/handlers/webpi.ashx/getinstaller/WindowsAzurePowershellGet.3f.3f.3fnew.appids ) " -ForegroundColor Yellow
        " "
    }
 
    Write-Host "Once the upgrade is done, run the script again. If the problem still persists see the Cloud Workload Protection online help (https://help.symantec.com/cs/SCWP/SCWP/v113454583_v111037498/Setting-up-an-Azure-connection/?locale=EN_US) or contact Symantec Support."
    " "
 }
