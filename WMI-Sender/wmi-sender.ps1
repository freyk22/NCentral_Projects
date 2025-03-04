<#   
WMI Sender
Description: powershell Function to save data to wmi class 
Example: fncsend_ncentral_wmi -itemkey_name Test1 -itemkey_value 21

#### Work in progress #####
#use at your own risk #
 
#> 

 
##functions 
function fncGetLogTimeStamp {return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)} 
function fnclog($logtext){Write-host "$(fncGetLogTimeStamp) $script_title - $logtext";} 
$script_title = "ncentral_sender_wmi" 

$device_id = “123”
$servicename = “PowerSupply”
$namespace = "ROOT\CIMV2\NCentral\$device_id"
$classname = "$servicename"



#========
#========
#method 1
#https://github.com/N-able/CustomMonitoring/blob/master/Exchange%202010%20DAG%20Status/ExchangeDAG.ps1

$NameSpace = "root\cimv2"
$ParentClass = "NCentral"
$SubClass = "NCentral_DAGCopyStatus"

fnclog "hi"
fnclog "check subbclass"
$tc = ([wmiclass]"\root\cimv2").getsubclasses() | where {$_.Name -eq $SubClass}	

if ($tc -eq $null){
    fnclog "check subbclass - cannot find it"

    #creating parentclass
    fnclog "creating parrentclass $ParentClass"
	$class = new-object wmiclass ("root\cimv2", [String]::Empty, $null)
	$class["__Class"] = $ParentClass
	$class.Qualifiers.Add("Static", $true)
	$class.Put()

    fnclog "creating subclass $subclass"
	[wmiclass]$subclass = $class.derive($SubClass)
	$subclass.Qualifiers.Add("Static", $false)
	$subclass.Properties.Add("Name", [System.Management.CimType]::String, $false)
	$subclass.Properties["Name"].Qualifiers.Add("Key", $true)
    $subclass.Properties.Add("Status", [System.Management.CimType]::String, $false)
	$subclass.Properties["Status"].Qualifiers.Add("Normal", $true)
    $subclass.Properties.Add("Value1",[System.Management.CimType]::String, $false)     
	$subclass.put()

    fnclog "Adding data"
    $mb = ([wmiclass]$SubClass).CreateInstance()
    $mb.Name = "jan" #$_.Name
    $mb.Status = "ok"
    $mb.Put()

    Get-WmiObject -Namespace "$NameSpace" -Class "$ParentClass"

    ##Adding new values to class 
    #fnclog "Saving WMI data - Adding Start values" 
    #$arglist = @{ 
    #    Value1 = "2" 
    #} 
    #Set-WmiInstance -Class "$SubClass" -Argument $arglist 
}


#=======
#=======
<#
#method 2
$wmiClassName = "ArcserveUDP2";
$wmi_namespace = "NCentral"
$wmiNameSpacePath = "root\cimv2\";
$itemkey_name = "object1"
$itemkey_value = "1"


fnclog "Saving WMI data - itemkey_name $itemkey_name" 
fnclog "Saving WMI data - itemkey_value $itemkey_value" 
fnclog "Saving WMI data - in: $wmiNameSpacePath $wmiClassName $wmi_Class_value"


$wminamespace_detect = Get-WmiObject -Namespace "$wmiNameSpacePath" -List
if($wminamespace_detect){
    fnclog "namespace is found";
}else{
    fnclog "namespace is not found";
    #Creates Namespace if doesn't exist, if exists will just overwrite
    fnclog "creating namespace"
    $Namespace=[wmiclass]'__namespace'
    $newNamespace=$Namespace.CreateInstance()
    $newNamespace.Name="$wmi_namespace" #'NCentral'
    $newNamespace.Put()
}

$wmiclass_detect = Get-WmiObject -Namespace "$wmiNameSpacePath" -List
#>




<##
fnclog "creating class"
Write-Host "$wmiClassName class does not exist, creating"
$class = New-Object System.Management.ManagementClass ($wmiNameSpacePath, [String]::Empty, $null)
$class["__CLASS"] = $wmiClassName
$class.Qualifiers.Add("Static", $true)
$class.Put()
#>




<#
Function fncsend_ncentral_wmi() 
{ 
  
 
    Param( 
        [Parameter(Mandatory = $true)] [string] $itemkey_name, 
        [Parameter(Mandatory = $false)] [string] $itemkey_value 
    )    
     
     
    $WMI_Namespace = 'root\cimv2' 
    $wmi_ClassName = $itemkey_name 
    $wmi_Class_value = $itemkey_value 
 
 
    #Remove-WmiObject -Class Test1 
 
    #Getting data 
    fnclog "Saving WMI data - itemkey_name $itemkey_name" 
    fnclog "Saving WMI data - itemkey_value $itemkey_value" 
    fnclog "Saving WMI data - in: $WMI_Namespace $wmi_ClassName $wmi_Class_value" 
 
    #Check if class excists 
    $WMI_class_check = Get-WmiObject -Namespace "$WMI_Namespace" -Class $wmi_ClassName 
     
    #if class is not found, create and fill class 
    if($true -ne $WMI_class_check){ 
        fnclog "Saving WMI data - class found not found"; 
         
        #Create a WMI class 
        fnclog "Saving WMI data - creating class $wmi_ClassName"; 
        $WMI_Class = "" 
        $WMI_Class = New-Object System.Management.ManagementClass("Root\cimv2", $null, $null) 
        $WMI_Class.name = $wmi_ClassName 
 
        #filling the new wmi class with properties 
        fnclog "Saving WMI data - filling new class with structure scheme in $wmi_ClassName"; 
         
        $WMI_Class["__CLASS"] = $wmi_ClassName 
        $WMI_Class.Properties.Add("Name", [System.Management.CimType]::String, $false) 
        $WMI_Class.Properties["Name"].Qualifiers.Add("key", $true) 
        $WMI_Class.Properties.Add("Value1",[System.Management.CimType]::String, $false) 
        $WMI_Class.Put() 
 
        #Adding new values to class 
        fnclog "Saving WMI data - Adding Start values" 
        $arglist = @{ 
            Value1 = "$wmi_Class_value" 
            Name = "name1" 
        } 
        Set-WmiInstance -Class $wmi_ClassName -Argument $arglist 
    } 
 
    #if class is found 
    if($WMI_class_check){ 
        fnclog "class updating"; 
        #$instance = Get-WmiObject -Namespace "$WMI_Namespace" -Class $wmi_ClassName 
        #$instance.Value1 = "$wmi_Class_value" 
        #$instance.Put() 
        $WMI_class_check.Value1 = "$wmi_Class_value" 
        $WMI_class_check.Put() 
    } 
} 
#>
#fncsend_nable_wmi end 
 
#fncsend_ncentral_wmi -itemkey_name "Test1" -

#============
#============
<#
function fncGetLogTimeStamp {return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)}
function fnclog($logtext){Write-host "$(fncGetLogTimeStamp) $scriptname - $logtext";}

$wmiClassName = "ArcserveUDP2";
$wmiNameSpacePath = "root\cimv2\NCentral";

fnclog "creating namespace"
#Creates Namespace if doesn't exist, if exists will just overwrite
$Namespace=[wmiclass]'__namespace'
$newNamespace=$Namespace.CreateInstance()
$newNamespace.Name='NCentral'
$newNamespace.Put()


fnclog "creating class"
Write-Host "$wmiClassName class does not exist, creating"
$class = New-Object System.Management.ManagementClass ($wmiNameSpacePath, [String]::Empty, $null)
$class["__CLASS"] = $wmiClassName
$class.Qualifiers.Add("Static", $true)
$class.Put()
#>
#========
#========
#========
#========
<#
#method Something
#get-wmiobject (deprecated)
#get-cimclass
#new-ciminstance
#set-wmiinstance
#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-wmiinstance?view=powershell-5.1


$device_id = "77"
$servicename = "PowerSupply77"
$path = "root\CIMV2\NCentral\Device_$($device_id)"

$subs = @($path -split '\\' | Select -Skip 1)
for ($i = 0; $i -lt $subs.Count; $i++)
{
    $sub = $subs[$i]
    write-host "creating $sub"
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

    Write-Host "Created namespace $sub under $alreadyExists" -f Green
}
#Get-WmiObject -Namespace Root/CIMV2/NCentral/Device_$($device_id) -Class __Namespace | Select Name
#Get-CimInstance -Namespace root\CIMV2\NCentral\Device_$($device_id) -Class __Namespace #| Select Name #| Select-Object -Last 1
#Get-CimInstance -Namespace $path -Class __Namespace
#$WMI_Class = New-Object System.Management.ManagementClass("root\CIMV2\NCentral\Device_1234", $null, $null)
$WMI_Class = New-Object System.Management.ManagementClass("root\CIMV2\NCentral\Device_$device_id", $null, $null)
#$WMI_Class.name = "Powersupply6" 
$WMI_Class.name = "$servicename" 
#filling the new wmi class properties 
$WMI_Class.Properties.Add("Devicename", [System.Management.CimType]::String, $false) 
$WMI_Class.Properties["Devicename"].Qualifiers.Add("key", $true) 
$WMI_Class.Properties.Add("Objectname",[System.Management.CimType]::String, $false) 
$WMI_Class.Put() 
#>




<#
#update class
fnclog "looking for $namespace - $classname "
$WMICim_class_check = Get-CimClass -Namespace $namespace -ClassName $servicename
#check class
if($WMICim_class_check){
        fnclog "Saving WMI data - class found found";
    }else{
        fnclog "Saving WMI data - class not found found";
}
fnclog "class updating";
$instance = Get-CimClass -Namespace $namespace -ClassName $servicename
$instance.CimClassProperties

$class = Get-CimClass -Namespace $namespace -ClassName $servicename
New-CimInstance -CimClass $class -Property @{"Objectname"="MyObject";"Devicename"="MyDevice";} #-ClientOnly
#>