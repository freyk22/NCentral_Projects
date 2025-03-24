<#   
WMI Sender
Description: powershell Function to save data to a wmi/cim class 

## Under construction - use at your own risk #

steps:
1. change script settings
2. add your script after function "ncentral_datatosend"
2. add to following line, for the data you want to send: ncentral_datatosend -item "myitem" -value "1234"
3. and end the script with the line: fncwmisender

#code example - adding/update data to collector
ncentral_datatosend -item "Objectname4" -value "1234"
fncwmisender;

#info:
https://documentation.n-able.com/N-central/userguide/Content/Services/Custom_Monitoring_Services/custom_mon_services_wmi.htm
https://github.com/N-able/CustomMonitoring
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-wmiinstance?view=powershell-5.1
https://www.reddit.com/r/PowerShell/comments/cmhtq8/wmi_sub_namespaces_syntax/?rdt=62918

## Under construction- use at your own risk #

#> 

### Settings ##
$script_title = "wmisender"
$Ncentral_device_customer = "mycustomer"
$NCentral_device_id = "112"
$NCentral_device_Name = "Myups"
$NCentral_servicename = "PowerSupply"
$Ncentral_wmi_namespace = "root\CIMV2\NCentral"

#dont change things behind this line
#dont change things behind this line
#==================================
#==================================
#==================================

function fncGetLogTimeStamp {return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)} #end function fncGetLogTimeStamp

function fnclog($logtext){Write-host "$(fncGetLogTimeStamp) $script_title - $logtext";} #end function fnclog

function fncwmisender {
    #function to create a namespace and the class
    
    function fncCimClassCreate {
    #function to create a namespace, class, instance and add properties to it.
        fnclog "Namespace creation - go"
        fnclog "Namespace creation - creating namespace $namespace"
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
        fnclog "Namespace creation - class created"
    
        #Creating class for device and add class properties to it
        fnclog "class creation - setting class properties in $($namespace)\$NCentral_servicename"
        $WMI_Class = New-Object System.Management.ManagementClass("$namespace", $null, $null)
        $WMI_Class.name = "$NCentral_servicename"
        $WMI_Class.Properties.Add("Devicename", [System.Management.CimType]::String, $false) 
        $WMI_Class.Properties["Devicename"].Qualifiers.Add("key", $true) 
        $WMI_Class.Properties.Add("Objectname",[System.Management.CimType]::String, $false) 
        foreach ($datasendcollector_dic_key in $datasendcollector_dic.Keys) {
                $WMI_Class.Properties.Add("$datasendcollector_dic_key",[System.Management.CimType]::String, $false) 
        }
        $WMI_Class.Put() 

        #creating instance
        fnclog "class creation - creating instance and adding data to it, in $($namespace)\$($NCentral_servicename)";
        $instancetofill = Get-CimClass -Namespace $namespace -ClassName $NCentral_servicename
        New-CimInstance -CimClass $instancetofill -Property $datasendcollector_dic #-ClientOnly
        fnclog "Namespace creation - done"
    }#end function fncCImclassCreate
    

    function fncInstance_Update{
        #updating instance
        fnclog "Update instance - go"
        fnclog "Update instance - Update instance with data in instance $($namespace)\$($NCentral_servicename)";
        $instancetoupdate = Get-CimClass -Namespace $($namespace) -ClassName $($NCentral_servicename) # | Where-Object "Device_id" -eq "$($NCentral_device_id)"
        #Set-CimInstance -InputObject $instancetoset -Property @{"Devicename"="ups1";"Objectname"="MyObject2";}
        #Get-CIMInstance -Classname $classname -Namespace $namespace | Where-Object Device_id -eq "$NCentral_device_id" | Set-CimInstance -Property @{Objectname3="3"}
        Set-CimInstance -InputObject $instancetoupdate -Property $datasendcollector_dic
        fnclog "Update instance - done"
    }#end fncInstance_Update
    
    #Setting value of Namespace
    $namespace = "$($Ncentral_wmi_namespace)\Device_$($NCentral_device_id)"

    #Adding to static values to $datasendcollector_dic
    $datasendcollector_dic = @{"Device_id" = $NCentral_device_id} + $datasendcollector_dic
    $datasendcollector_dic = @{"Devicename" = $NCentral_device_Name} + $datasendcollector_dic
    $datasendcollector_dic = @{"Device_customer" = $Ncentral_device_customer } + $datasendcollector_dic
    
    foreach ($datasendcollector_dic_key in $datasendcollector_dic.Keys) {
        fnclog "Data-send collector - collectordata - $($datasendcollector_dic_key)=$($datasendcollector_dic[$datasendcollector_dic_key])"                                                                 
    }

    #check for namespace
    fnclog "Namespace creation - creating namespace: $namespace"
    fnclog "Namespace creation - checking if namespace excists"
    $Simclassdetect = Get-CimClass -Namespace $namespace -ClassName $NCentral_servicename -ErrorAction Ignore
    if($Simclassdetect){
        fnclog "Class detection - class found";
        fncInstance_Update
    }else{
        fnclog "Class dectection - class not found";
        fncCimClassCreate;
    }
            
    fnclog "datasender - done"

}#end function fncNamespacecreate

function ncentral_datatosend {
    #function to save data in dictionary
    param( [parameter(Mandatory=$true)] [string]$item,[string]$value) 
    fnclog "Data-send collector - adding to collector: $($item)=$($value)"
    $datasendcollector_dic.Add("$item", "$value")    
} #end function ncentral_datatosend

#create data collector
fnclog "data-send collector - Preparing data-send collector"
Set-Variable -Name datasendcollector_dic -Option AllScope
$datasendcollector_dic = @{}

#==================================
#==================================
#==================================
#dont change things above this line
#dont change things above this line



## Add your reader script here
## Add your reader script here
## Add your reader script here


#Add data to send. (but deviceid, devicename en devicecostumer al already sended)
fnclog "data-send collector - Adding Data"
ncentral_datatosend -item "Objectname" -value "12345"
ncentral_datatosend -item "Objectname2" -value "2222"
ncentral_datatosend -item "Objectname3" -value "3333"
ncentral_datatosend -item "Objectname4" -value "4444"

#send all the data to the wmi sender
fncwmisender #-namespace $namespace