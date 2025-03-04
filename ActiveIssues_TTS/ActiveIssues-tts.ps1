<#
Active Issues tts

A powershell script dat reads N-central Active issues out loud, using a TTS Engine.
== Work in progress - use at your own risk ==

#>



function fncGetLogTimeStamp {return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)}
function fnclog($logtext){Write-host "$(fncGetLogTimeStamp) $scriptname - $logtext";}
$scriptname = "api-tts"

$api_site = "https://myncentralserver/api"
$apiKey = "yourapikey"


function fnc_api_request {
    Param([Parameter(Mandatory = $true)] [string] $request,[Parameter(Mandatory = $true)] [string] $method)
    $api_request = $request
    $api_Url = "$api_site/$api_request"
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }
    fnclog "api request: $api_request"
    $response = Invoke-RestMethod -Uri $api_Url -Method $method -Headers $headers | ConvertTo-Json -Depth 10
    return $response
}
#fnc_api_request -Method "Get" -request "health"
#fnc_api_request -Method "Get" -request "auth"
#fnc_api_request -Method "Get" -request " "
#$ncentral_health = fnc_api_request -Method "Get" -request "health"
#$ncentral_health_resultObject = ConvertFrom-JSON -InputObject $ncentral_health
#$ncentral_health_resultObject.currentTime


$schema = @'
{
  "data": [
    {
      "orgUnitId": 102,
      "deviceId": 576589254,
      "notificationState": 5,
      "serviceId": 496,
      "serviceName": "Windows UAC Status",
      "serviceType": "AMP",
      "taskId": 2096172314,
      "serviceItemId": 36893,
      "_extra": {
        "numberOfAcknowledgedNotification": null,
        "avdUpdateServerEnabled": false,
        "licenseMode": "Professional",
        "psaIntegrationDisabled": false,
        "avdProtectionEnabled": true,
        "remoteControllable": true,
        "reactiveSupported": true,
        "partOfNotification": false,
        "remoteControlState": "disconnected",
        "acknowledgedBy": "",
        "avdVersion": "",
        "deviceName": "NCC-9996",
        "ticketCreationInProgress": null,
        "transitionTime": "2024-04-02T16:15:33.432Z",
        "integrationStatuses": [],
        "lwtEdrStatus": "",
        "patchManagementEnabled": false,
        "backupManagerProfile": "",
        "mspBackupProfile": "",
        "securityManagerProfile": "",
        "notificationAcknowledgmentInProgress": false,
        "taskIdent": "",
        "microsoftPatchManagementEnabled": false,
        "deviceClassValue": null,
        "backupManagerVersion": "",
        "securityManagerVersion": "",
        "remoteControlConnected": null,
        "monitoringDisabled": false,
        "numberOfActiveNotification": 0,
        "psaIntegrationExists": false,
        "lwtEdrEnabled": false,
        "mspBackupVersion": "",
        "thirdPartyPatchManagementEnabled": false,
        "probe": false,
        "reactiveEnabled": true,
        "netPathEnabled": false,
        "deviceClassLabel": null,
        "mspBackupEnabled": false,
        "port": "",
        "diskEncryptionEnabled": false,
        "customerTree": [
          "System",
          "Service_Organization",
          "Customer 2"
        ],
        "securityManagerEnabled": false,
        "psaTicketDetails": "",
        "soCustomerID": 50,
        "maintenanceWindowEnabled": false,
        "backupManagerEnabled": false,
        "patchManagementProfile": ""
      }
    }
  ],
  "pageNumber": 0,
  "pageSize": 0,
  "itemCount": 0,
  "totalItems": 0,
  "totalPages": 0,
  "_links": {
    "firstPage": "string",
    "previousPage": "string",
    "nextPage": "string",
    "lastPage": "string"
  },
  "_warning": "string"
}
'@

$apiresponse_ori = ConvertFrom-JSON -InputObject $schema

$orgunitid = $apiresponse_ori.data.orgUnitId
$notificationState = $apiresponse_ori.data.notificationState
$devicename = $apiresponse_ori.data._extra.deviceName
$text = "alarm - notificationstate is $notificationState for device found on device $devicename at customer $orgunitid"

<#
$PlayWav=New-Object System.Media.SoundPlayer
$PlayWav.SoundLocation=’C:\Windows\Media\Notify.wav’

$voice = New-Object -ComObject SAPI.SpVoice
$Voice.Volume = 10
$Voice.Rate = -2

$PlayWav.playsync()
$voice.Speak($text)
$PlayWav.playsync()
$voice.Speak($text)
#>

<#
while ($true) {
    
     Start-Sleep -s 60
	 run_functionTTS
}
#>
