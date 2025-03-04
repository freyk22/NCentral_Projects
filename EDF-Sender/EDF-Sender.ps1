<#
N-central edf sender

Script created by Freyk 2024/2025
Works on Linux, not yet on windows.
Use at your own risk

Version: Concept mode.

== Description ===
Ncentral edf sender,  a script that sends metrics data to n-central server, using N-central External data feed service.

== Installation - Add n-central service and template ==
1. download https://files.n-able.com/NRCNable/media/Custom-Monitoring/EDF-SDK.zip
2. creat a service by Extracting the zipfile and import file "GenericApplication.xml" in ncentral Administration -> Service Management -> Custom > GenericApplication.xml
3. In the Data and Thresholds tab, click Add Metric.
4. In the Configure Metric dialog box, type the Metric name.
5. From the Data Type drop-down menu, select the appropriate value for the data that is being reported back by the EDF Agent.
6. Select the Unit if the metric being measured should scale automatically based on the data being collected.
7. It is critical that you select the appropriate type of data for a metric. If an inappropriate metric is selected, N-able N-central will not accept the data being reported by the EDF Agent and the service will transition to a Stale state.
8. Click Save.
9 add the created service to a device
10. ncentral device > monitoring options > Check “edf enabled”
11. end


== Installation - script ==
1. Add service to device
2. enable EDF in device: ncentral device > monitoring options > "edf enabled" check (??)
1. Activationcode is edf-code of device. items are the parts of the device. write activation code in the script settings
2. install on the system "powershell" and java runtime (like "java-23-openjdk")
3. on the system download EDF-SDK zip-file from: https://files.n-able.com/NRCNable/media/Custom-Monitoring/EDF-SDK.zip
4. extract the content of this zip-file to a folder, named "edf"
5. change the value of "endpointURL" to the addres to the n-central server, in files "edf\resources\EDFGenericApp_en_CA.properties" and "edf\resources\EDFGenericApp_en_US.properties"
7. change the script settings below. 
8. change operatingsystem things in the EDF-folderpath and java classpath. 
for windows change the  ":" (for linux) to ";" (for windows) (and vise versa) 
for Windows change "/" (for linux) to windows "/" (and vise versa) (forward and backslash, change ":" to ";" in java classpath)
9. Create your own script that gets the data from a device/api 
10. use functions "fncncentral_edf_senddatatable_add_string_dic" to add data and "fncncentraledfsend" to send data with edf.


== Installation in short, (linux): ==
wget https://files.n-able.com/NRCNable/media/Custom-Monitoring/EDF-SDK.zip; 
mkdir edf; mv EDF-SDK.zip ./edf; cd edf; unzip EDF-SDK.zip; rm EDF-SDK.zip;
zypper addrepo https://download.opensuse.org/repositories/home:marcinbajor/openSUSE_Tumbleweed/home:marcinbajor.repo; 
zypper refresh; zypper install powershell java-23-openjdk;

== Installation in short, (windows): ==
md c:\temp\
cd c:\temp
curl -O "https://files.n-able.com/NRCNable/media/Custom-Monitoring/EDF-SDK.zip"
md c:\temp\edf
tar -xf .\EDF-SDK.zip -C c:\temp\edf; erase EDF-SDK.zip
winget install --id=Oracle.JavaRuntimeEnvironment -e
curl -Ol https://javadl.oracle.com/webapps/download/AutoDL?BundleId=251656_7ed26d28139143f38c58992680c214a5
java runtime: 
https://www.java.com/en/download/manual.jsp
#>



#Get script inputparameters
#param([Parameter(Mandatory=$true)] [string] $ACTIVATIONCODE)

#== Settings - ncentral Proxy ===
#ipadres of ncentral server/proxy
$ncentralserver = "https://admin.mydomain.com"


#== Settings - Device == "
$ACTIVATIONCODE = "23353b4-3cef" #"12345"
$Device_Name = "23353b4-3cef"
$device_ActivationCode = "23353b4-3cef"


#==Settings - Script#
#folder location of EDF-Folder
$edfpath = "/home/user/edf"


# Dont change anything, behind the following line
#=====================================================
#=====================================================
#=====================================================
#=====================================================
#=====================================================
#=====================================================

$scriptname = "Ncentral Sender EDF"
$ncentralscripterror_itemkey = "script_error"


#check powershell policy
<#
$CurrentPolicy = Get-ExecutionPolicy
If ($CurrentPolicy -ne 'RemoteSigned')
    {
        WRITE-HOST "The current execution policy is set to $CurrentPolicy - this is a bad thing!"
        WRITE-HOST "I'll try to set the execution policy to 'RemoteSigned' - just a sec."
        SET-EXECUTIONPOLICY Unrestricted
        RETURN
    }
#>

#function for logging
function fncGetLogTimeStamp {return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)}
function fnclog($logtext){Write-host "$(fncGetLogTimeStamp) $scriptname - $logtext";}
Function fncncentralsenderror{fnclog "error in script. Bye"; exit;}

fnclog “start”

<#
##function to save data in array
Set-Variable -Name ncentral_edf_senddatatable_arr -Option AllScope
$ncentral_edf_senddatatable_arr = @()
function fncncentral_edf_senddatatable_add_array{
    param( [parameter(Mandatory=$true)] [string]$item1,[string]$value1) 
    fnclog "adding $item1 and $value1"
    $ncentral_edf_senddatatable_arr += "`"$($item1):$($value1)`""
}
fncncentral_edf_senddatatable_add_array -item "SCANDETAIL4NAME" -value "SCANDETAIL4VALUE"
fncncentral_edf_senddatatable_add_array -item "SCANDETAIL5NAME" -value "SCANDETAIL5VALUE"
fncncentral_edf_senddatatable_add_array -item "SCANDETAIL6NAME" -value "SCANDETAIL6VALUE"
java -cp $CPATH $java_app $ACTIVATIONCODE $(Foreach ($i in $ncentral_edf_senddatatable_arr){$i;})
#>



##function to save data in dictionary
fnclog "Data-send table - Preparing data-send dictionary table"
Set-Variable -Name ncentral_edf_senddatatable_dic -Option AllScope
Set-Variable -Name ncentral_edf_senddatatable_arr -Option AllScope
$ncentral_edf_senddatatable_dic = @{}
function fncncentral_edf_senddatatable_add_string_dic{
    param( [parameter(Mandatory=$true)] [string]$item,[string]$value) 
    fnclog "Data-send table - adding to table: $item and $value"
    $ncentral_edf_senddatatable_dic.Add("$item", "$value")    
}
fncncentral_edf_senddatatable_add_string_dic -item "SCANDETAIL4NAME" -value "SCANDETAIL4VALUE"
fncncentral_edf_senddatatable_add_string_dic -item "SCANDETAIL5NAME" -value "SCANDETAIL5VALUE"
fncncentral_edf_senddatatable_add_string_dic -item "SCANDETAIL6NAME" -value "SCANDETAIL6VALUE"


<#
fnclog "Data-send table - converting data-send dictionary to arry for sending"
$ncentral_edf_senddatatable_arr = @()
$ncentral_edf_senddatatable_dic.keys | ForEach-Object {
    $ncentral_edf_senddatatable_arr += "`"$($_):$($ncentral_edf_senddatatable_dic[$_])`""
}
#sending data
java -cp $CPATH $java_app $ACTIVATIONCODE $(Foreach ($i in $ncentral_edf_senddatatable_arr){$i;})
#end function save data to dctionary
#>

<#
#old code
    $CPATH="$edfpath/axis/WEB-INF/lib/commons-collections-2.1.1.jar:$edfpath/axis/WEB-INF/lib/jline.jar:$edfpath/axis/WEB-INF/lib/axis.jar:$edfpath/axis/WEB-INF/lib/commons-digester.jar:$edfpath/axis/WEB-INF/lib/log4j-1.2.8.jar:$edfpath/axis/WEB-INF/lib/bcprov-jdk14-126.jar:$edfpath/axis/WEB-INF/lib/commons-discovery.jar:$edfpath/axis/WEB-INF/lib/jaxrpc.jar:$edfpath/axis/WEB-INF/lib/saaj.jar:$edfpath/axis/WEB-INF/lib/commons-beanutils.jar:$edfpath/axis/WEB-INF/lib/commons-logging.jar:$edfpath/axis/WEB-INF/lib/wsdl4j.jar:$edfpath/axis/WEB-INF/lib/dmsapi.jar:$edfpath/jar/EDFGenApp.jar:$edfpath/resources"
    $java_app = "com.nable.server.edf.GenericApp.EDFGenericApp"
    $SCANDETAIL1NAME = "SCANDETAIL1NAME"; $SCANDETAIL1VALUE = "SCANDETAIL1VALUE";
    $SCANDETAIL2NAME = "SCANDETAIL2NAME"; $SCANDETAIL2VALUE = "SCANDETAIL2VALUE";
    $SCANDETAIL3NAME = "SCANDETAIL3NAME"; $SCANDETAIL3VALUE = "SCANDETAIL3VALUE";
    fnclog "sending data - settings - ACTIVATIONCODE = $ACTIVATIONCODE"
    fnclog "sending data - settings - SCANDETAIL1NAME = $SCANDETAIL1NAME - $SCANDETAIL1VALUE"
    fnclog "sending data - settings - SCANDETAIL2NAME = $SCANDETAIL2NAME - $SCANDETAIL2VALUE"
    fnclog "sending data - settings - SCANDETAIL3NAME = $SCANDETAIL3NAME - $SCANDETAIL3VALUE"
    java -cp $CPATH $java_app $ACTIVATIONCODE "${SCANDETAIL1NAME}:$SCANDETAIL1VALUE" "${SCANDETAIL2NAME}:$SCANDETAIL2VALUE" "${SCANDETAIL3NAME}:$SCANDETAIL3VALUE" 
#>



Function fncncentraledfsend
{   
    
    fnclog "sending data - procedure start"

    fnclog "settings check - check EDF endpoint"
    $endpoint_edf_url = $ncentralserver + "/dms/services/EDFService"
    $endpoint_edf_configval_ori = "endpointURL=" + $endpoint_edf_url
    $endpoint_edf_configval_1 = $(Get-Content $edfpath/resources/EDFGenericApp_en_CA.properties | Select-String -Pattern endpointURL).line
    $endpoint_edf_configval_2 = $(Get-Content $edfpath/resources/EDFGenericApp_en_US.properties | Select-String -Pattern endpointURL).line
    fnclog "settings check - check endpoint edf - endpointori $endpoint_edf_configval_ori"
    fnclog "settings check - check endpoint edf - endpoint1 $endpoint_edf_configval_1"
    if($endpoint_edf_configval_1 -eq $endpoint_edf_configval_ori){fnclog "settings check - check endpoint edf - endpoint1 ok"}else{fnclog "settings check - check endpoint edf - endpoint1 - error";}
    fnclog "settings check - check endpoint edf - endpoint2 $endpoint_edf_configval_2"
    if($endpoint_edf_configval_2 -eq $endpoint_edf_configval_ori){fnclog "settings check - check endpoint edf - endpoint2 ok"}else{fnclog "settings check - check endpoint edf - endpoint2 - error";}
    fnclog "settings check - check endpoint edf site - $endpoint_edf_url"
    $endpoint_edf_sitecheck = [net.WebRequest]::Create($endpoint_edf_url)
    if($endpoint_edf_sitecheck.GetResponse().StatusCode){fnclog "settings check - check endpoint edf site - ok";}else{fnclog "settings check - check endpoint edf site - error";}
    
    #preparing edf sender
    
    <#
    fnclog "Method 0"
    $CPATH="$edfpath/axis/WEB-INF/lib/commons-collections-2.1.1.jar:$edfpath/axis/WEB-INF/lib/jline.jar:$edfpath/axis/WEB-INF/lib/axis.jar:$edfpath/axis/WEB-INF/lib/commons-digester.jar:$edfpath/axis/WEB-INF/lib/log4j-1.2.8.jar:$edfpath/axis/WEB-INF/lib/bcprov-jdk14-126.jar:$edfpath/axis/WEB-INF/lib/commons-discovery.jar:$edfpath/axis/WEB-INF/lib/jaxrpc.jar:$edfpath/axis/WEB-INF/lib/saaj.jar:$edfpath/axis/WEB-INF/lib/commons-beanutils.jar:$edfpath/axis/WEB-INF/lib/commons-logging.jar:$edfpath/axis/WEB-INF/lib/wsdl4j.jar:$edfpath/axis/WEB-INF/lib/dmsapi.jar:$edfpath/jar/EDFGenApp.jar:$edfpath/resources"
    $java_app = "com.nable.server.edf.GenericApp.EDFGenericApp"
    $SCANDETAIL1NAME = "SCANDETAIL1NAME"; $SCANDETAIL1VALUE = "SCANDETAIL1VALUE";
    $SCANDETAIL2NAME = "SCANDETAIL2NAME"; $SCANDETAIL2VALUE = "SCANDETAIL2VALUE";
    $SCANDETAIL3NAME = "SCANDETAIL3NAME"; $SCANDETAIL3VALUE = "SCANDETAIL3VALUE";
    fnclog "sending data - settings - ACTIVATIONCODE = $ACTIVATIONCODE"
    fnclog "sending data - settings - SCANDETAIL1NAME = $SCANDETAIL1NAME - $SCANDETAIL1VALUE"
    fnclog "sending data - settings - SCANDETAIL2NAME = $SCANDETAIL2NAME - $SCANDETAIL2VALUE"
    fnclog "sending data - settings - SCANDETAIL3NAME = $SCANDETAIL3NAME - $SCANDETAIL3VALUE"
    fnclog "Activation Code: $ACTIVATIONCODE"
    fnclog "$SCANDETAIL1NAME":\"$SCANDETAIL1VALUE\"
    fnclog "$SCANDETAIL2NAME":\"$SCANDETAIL2VALUE\"
    java -cp $CPATH com.nable.server.edf.GenericApp.EDFGenericApp $ACTIVATIONCODE "${SCANDETAIL1NAME}:$SCANDETAIL1VALUE" "${SCANDETAIL2NAME}:$SCANDETAIL2VALUE" "${SCANDETAIL3NAME}:$SCANDETAIL3VALUE" 
    #>


    fnclog "Method 1"
    fnclog "preparing edf sender"
    $CPATH="$edfpath/axis/WEB-INF/lib/*:$edfpath/jar/EDFGenApp.jar:$edfpath/resources"
    $java_app = "com.nable.server.edf.GenericApp.EDFGenericApp"

    $SCANDETAIL1NAME = "SCANDETAIL1NAME"; $SCANDETAIL1VALUE = "SCANDETAIL1VALUE";
    $SCANDETAIL2NAME = "SCANDETAIL2NAME"; $SCANDETAIL2VALUE = "SCANDETAIL2VALUE";
    $SCANDETAIL3NAME = "SCANDETAIL3NAME"; $SCANDETAIL3VALUE = "SCANDETAIL3VALUE";
    fnclog "sending data - settings - ACTIVATIONCODE = $ACTIVATIONCODE"
    fnclog "sending data - settings - SCANDETAIL1NAME = $SCANDETAIL1NAME - $SCANDETAIL1VALUE"
    fnclog "sending data - settings - SCANDETAIL2NAME = $SCANDETAIL2NAME - $SCANDETAIL2VALUE"
    fnclog "sending data - settings - SCANDETAIL3NAME = $SCANDETAIL3NAME - $SCANDETAIL3VALUE"
    fnclog "Sending data  - start process.."
    java -cp $CPATH $java_app $ACTIVATIONCODE "${SCANDETAIL1NAME}:$SCANDETAIL1VALUE" "${SCANDETAIL2NAME}:$SCANDETAIL2VALUE" "${SCANDETAIL3NAME}:$SCANDETAIL3VALUE" 
    fnclog "==="    
    fnclog "=============================="
    fnclog "=============================="
    
    fnclog "Method 2"
    fnclog "Data-send table - converting data-send dictionary to arry for sending"
    $ncentral_edf_senddatatable_arr = @()
    $ncentral_edf_senddatatable_dic.keys | ForEach-Object {$ncentral_edf_senddatatable_arr += "`"$($_):$($ncentral_edf_senddatatable_dic[$_])`""}
    [string]$senddata = $(Foreach ($i in $ncentral_edf_senddatatable_arr){"$i";})
    fnclog "sending data - datatable string = $senddata"
    fnclog "Sending data  - start process.."
    $ncentraldatasend_process_stdOutTempFile = "/tmp/$((New-Guid).Guid)" #"$env:temp\$((New-Guid).Guid)"
    $ncentraldatasend_process_stdErrTempFile = "/tmp/$((New-Guid).Guid)" #"$env:temp\$((New-Guid).Guid)" 
    $ncentraldatasend_process = Start-Process -FilePath "java" -ArgumentList "-cp", $CPATH, $java_app, $ACTIVATIONCODE,$senddata -NoNewWindow -RedirectStandardError $ncentraldatasend_process_stdErrTempFile -RedirectStandardOutput $ncentraldatasend_process_stdOutTempFile -PassThru -Wait
    $ncentraldatasend_process_output = Get-Content -Path $ncentraldatasend_process_stdOutTempFile -Raw
    $ncentraldatasend_process_error = Get-Content -Path $ncentraldatasend_process_stdErrTempFile -Raw
    fnclog "sending data - process output:`n$ncentraldatasend_process_output$ncentraldatasend_process_error"
    fnclog "sending data - analysing output..."
    fnclog "sending data - process exitcode: $($ncentraldatasend_process.ExitCode)"
    if (-Not [String]::IsNullOrWhiteSpace((Get-content $ncentraldatasend_process_stdErrTempFile))){
        fnclog "sending data - process  - error check - ERROR - output: $ncentraldatasend_process_error";
    }else{
        fnclog "sending data - process - error check - OK error found - output: $ncentraldatasend_process_error";
    }   
    Remove-Item $ncentraldatasend_process_stdOutTempFile, $ncentraldatasend_process_stdErrTempFile -ErrorAction SilentlyContinue
   
    <#
    [string]$senddata = $(Foreach ($i in $ncentral_edf_senddatatable_arr){"$i";})
    $process = Start-Process -FilePath "java" -ArgumentList "-cp", $CPATH, $java_app, $ACTIVATIONCODE, $senddata -NoNewWindow -PassThru -Wait
    #>

}
fncncentraledfsend

fnclog "Done"
fnclog “end”
#end procedure