<#   
== Description ===

A powershell function that saves metrics from applications/devices to the wmi database.
Metrics will be temporary saved in a array and the concent will be saved in the wmi database.

## Under construction - use at your own risk #

== Examples input ==
#Example - adding data to collector
ncentral_datatosend -item "Objectname4" -value "4444"
#Example - create namespace
fncCimClassCreate -namespace $namespace
#update data in class
Get-CIMInstance -Classname $servicename -Namespace $namespace | Where-Object Device_id -eq "$device_id" | Set-CimInstance -Property $datasendcollector_dic

## Under construction- use at your own risk #

#info:
https://documentation.n-able.com/N-central/userguide/Content/Services/Custom_Monitoring_Services/custom_mon_services_wmi.htm
#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-wmiinstance?view=powershell-5.1
#https://www.reddit.com/r/PowerShell/comments/cmhtq8/wmi_sub_namespaces_syntax/?rdt=62918
 
#> 

function fncGetLogTimeStamp {return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)} 
function fnclog($logtext){Write-host "$(fncGetLogTimeStamp) $script_title - $logtext";} 
$script_title = "wmisender"

$device_id = "112"
$namespace = "root\CIMV2\NCentral\Device_$($device_id)"
$servicename = "PowerSupply"

fnclog "data-send collector - Preparing data-send collector"
Set-Variable -Name datasendcollector_dic -Option AllScope
$datasendcollector_dic = @{}

function ncentral_datatosend {
    #function to save data in dictionary
    param( [parameter(Mandatory=$true)] [string]$item,[string]$value) 
    fnclog "Data-send collector - adding to collector: $($item)=$($value)"
    $datasendcollector_dic.Add("$item", "$value")    
}
fnclog "data-send collector - Adding Data"
ncentral_datatosend -item "Device_id" -value "$device_id"
ncentral_datatosend -item "Devicename" -value "ups1"
ncentral_datatosend -item "Device_customer" -value "12345"
ncentral_datatosend -item "Objectname" -value "12345"
ncentral_datatosend -item "Objectname2" -value "2222"
ncentral_datatosend -item "Objectname3" -value "3333"
ncentral_datatosend -item "Objectname4" -value "4444"


#display content of the collector
foreach ($datasendcollector_dic_key in $datasendcollector_dic.Keys) {
        fnclog "Data-send collector - collectordata - $($datasendcollector_dic_key)=$($datasendcollector_dic[$datasendcollector_dic_key])"                                                                 
}

function fncCimClassCreate {
    #function to create a namespace and the class
    param( [parameter(Mandatory=$true)] [string]$namespace)
    fnclog "creating namespace $namespace - go"
    write-host "============================="

    $subs = @($namespace -split '\\' | Select -Skip 1)
    for ($i = 0; $i -lt $subs.Count; $i++)
    {
        $sub = $subs[$i]
        write-host "creating class $sub"
        $list = New-Object System.Collections.ArrayList
        [void]$list.Add("root")
        $list.AddRange(@($subs | Select -First $i))
        $alreadyExists = $list -join '\'
        $nsPath = "{0}:__NAMESPACE" -f $alreadyExists
        # create the namespace
        $ns = [wmiclass]$nsPath
        $sc = $ns.CreateInstance()
        $sc.Name = $sub
        $sc.Put()
        write-host "----"
        #fnclog "Created namespace $sub under $alreadyExists" #-f Green
    }
    write-host "============================="
    fnclog "creating namespace $namespace - done"

}#end function fncCimClassCreate
fncCimClassCreate -namespace $namespace

#Creating class for device and add class properties to it
fnclog "creating class for service $servicename in $namespace" 
fnclog "setting class properties in $($namespace)\$servicename"
$WMI_Class = New-Object System.Management.ManagementClass("$namespace", $null, $null)
$WMI_Class.name = "$servicename"
$WMI_Class.Properties.Add("Devicename", [System.Management.CimType]::String, $false) 
$WMI_Class.Properties["Devicename"].Qualifiers.Add("key", $true) 
$WMI_Class.Properties.Add("Objectname",[System.Management.CimType]::String, $false) 
foreach ($datasendcollector_dic_key in $datasendcollector_dic.Keys) {
        $WMI_Class.Properties.Add("$datasendcollector_dic_key",[System.Management.CimType]::String, $false) 
}
$WMI_Class.Put() 

#creating instance
fnclog "creating instance and adding data to it, in $($namespace)\$($servicename)";
$instancetofill = Get-CimClass -Namespace $namespace -ClassName $servicename
New-CimInstance -CimClass $instancetofill -Property $datasendcollector_dic #-ClientOnly

#updating instance
fnclog "Update data in instance $namespace \ $servicename";
$instanceset = Get-CimClass -Namespace $namespace -ClassName $servicename
if($instanceset){
        fnclog "update instance - instance found found";
    }else{
        fnclog "updating instance - instance not found found";
}
#Set-CimInstance -InputObject $instanceset -Property @{"Devicename"="ups1";"Objectname"="MyObject2";}
#Set-CimInstance -InputObject $instanceset -Property $datasendcollector_dic
#Get-CIMInstance -Classname $classname -Namespace $namespace | Where-Object Device_id -eq "$device_id" | Set-CimInstance -Property @{Objectname3="3"}
Get-CIMInstance -Classname $servicename -Namespace $namespace | Where-Object Device_id -eq "$device_id" | Set-CimInstance -Property $datasendcollector_dic

fnclog "done"