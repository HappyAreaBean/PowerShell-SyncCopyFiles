[int]$numberlobbyies;
[int]$Mode;
[boolean]$DebugMode = $false;

[string]$FromLocation = "./Lobby/testcopy/1"
[string]$FromPluginsLocation = "$FromLocation/plugins/"
[string]$FromFilesLocation = "$FromLocation/"

[string]$Destination = "./Lobby/testcopy"
[string]$DestinationPluginsLocation = "/plugins/"
[string]$DestinationFilesLocation = "$Destination/"

$PluginsList = New-Object -TypeName "System.Collections.ArrayList"
$PluginsList.Add("PlaceholderAPI")
$PluginsList.Add("ServerNPC")

$FilesList = New-Object -TypeName "System.Collections.ArrayList"
$FilesList.Add("spigot.yml")
$FilesList.Add("paper.yml")
$FilesList.Add("ImanitySpigot.jar")
$FilesList.Add("imanity")

function selectMode {
    param (
        [string]$Title = "Please select which copy mode"
    )
    Clear-Host
    printTitle -Title $Title

    Write-Host "1. Copy to each lobby"
    Write-Host "2. Copy to specific lobby"
    
    printTitle -Title $Title 

    $ReadSelectedMode = Read-Host "Please select a mode"
    switch ($ReadSelectedMode) {
        "1" {
            Clear-Host

            printTitle
            Write-Host "Please enter the lobby number of the range you want to copy"
            Write-Host "We will autoremove the 0 and skip if the location is same"
            Write-Host 
            Write-Host "Type -1 to exit."
            printTitle
            [int]$LobbyAmountEnter = Read-Host "Enter Number"

            if ($LobbyAmountEnter -eq -1) {
                selectMode
                return
            }

            Clear-Host
                
            printTitle
            Write-Host "               Copying Plugins"
            printTitle

            runCopy -MultipleLobby $true -AddSlashBefore $true -LobbyNumber $LobbyAmountEnter -FileList $PluginsList -FinalFrom $FromPluginsLocation -FinalDestination $Destination -AdditionalDestination $DestinationPluginsLocation

            printTitle
            Write-Host "               Copying Files"
            printTitle

            runCopy -MultipleLobby $true -AddSlashAfter $true -LobbyNumber $LobbyAmountEnter -FileList $FilesList -FinalFrom $FromFilesLocation -FinalDestination $DestinationFilesLocation

            printTitle -Title "Copy Completed"
        } 
        "2" {
            Clear-Host

            printTitle
            Write-Host "Please enter the lobby number you want to copy"
            Write-Host 
            Write-Host "Type -1 to exit."
            printTitle
            [int]$LobbyAmountEnter = Read-Host "Enter Number"

            if ($LobbyAmountEnter -eq -1) {
                selectMode
                return
            }


            Clear-Host
                
            printTitle
            Write-Host "               Copying Plugins"
            printTitle

            runCopy -MultipleLobby $false -AddSlashBefore $true -LobbyNumber $LobbyAmountEnter -FileList $PluginsList -FinalFrom $FromPluginsLocation -FinalDestination $Destination -AdditionalDestination $DestinationPluginsLocation

            printTitle
            Write-Host "               Copying Files"
            printTitle

            runCopy -MultipleLobby $false -LobbyNumber $LobbyAmountEnter -FileList $FilesList -FinalFrom $FromFilesLocation -FinalDestination $DestinationFilesLocation -AdditionalDestination "/"

            printTitle -Title "Copy Completed"
        }
        'q' {
            exit
        }
        '-1' {
            exit
        }
        Default {
            selectMode
        }
    }
}

function runCopy {
    param (
        [boolean]$MultipleLobby,
        [boolean]$AddSlashBefore,
        [boolean]$AddSlashAfter,
        [int]$LobbyNumber,
        [string[]]$FileList,
        [string]$FinalFrom,
        [string]$FinalDestination,
        [string]$AdditionalDestination
    )

    if ($AddSlashBefore) {
        $BeforeSlash = "/"
    }

    if ($AddSlashAfter) {
        $AfterSlash = "/"
    }

    for ($FileInt = 0; $FileInt -lt $FileList.Count; $FileInt++) {
        [string]$FilesName = $FileList[$FileInt]

        Write-Host
        Write-Host "------------------------ [ $FilesName ] ------------------------"

        if ($MultipleLobby) {
            for ($LobbyInt = 0; $LobbyInt -lt $LobbyNumber + 1; $LobbyInt++) {
                $From = "$FinalFrom$FilesName";
                $To = "$FinalDestination$BeforeSlash$LobbyInt$AfterSlash$AdditionalDestination$FilesName";
                if ( $LobbyInt -ne 0 -and "$From" -ne "$To") {
                    Write-Host
                    debuglog -Message "[DEBUG] From: $From | To: $To"

                    copyFiles -From $From -To $To -LobbyNumber $LobbyInt -FilesName $FilesName
                }
            }
        } else {
            $From = "$FinalFrom$FilesName";
            $To = "$FinalDestination$LobbyNumber$AdditionalDestination$FilesName";
            debuglog -Message "[DEBUG] From: $From | To: $To"

            copyFiles -From $From -To $To -LobbyNumber $LobbyNumber -FilesName $FilesName
        }
    }
    
}

function copyFiles {
    param (
        [string]$From,
        [string]$To,
        [int]$LobbyNumber,
        [string]$FilesName
    )

    # [string]$FilesName = (Get-Item -Path "$From").Name
    # if ($To -eq $From) {
    #     Write-Host "The file $FilesName doesn't exist... Skipping..."
    #     return
    # }

    if (Test-Path -Path $To) {
        deleteItem -Location $To
        Write-Host "Deleting Lobby [$LobbyNumber] exist $FilesName files..."

        debuglog -Message "[DEBUG] Lobby $LobbyNumber passed remove | Location - From: $From - Destination: $To"
    } else {
        Write-Host "The file $FilesName doesn't exist... Skip remove..."
        debuglog -Message "[DEBUG] Lobby $LobbyNumber did not passed remove | Location - From: $From - Destination: $To"
    }

    if ("$To" -ne "$From") {
        if (Test-Path -Path $From) {
            copyItem -From $From -To $To
            Write-Host "Copying $FilesName to Lobby [$LobbyNumber]"
        } else {
            Write-Host "The file $FilesName doesn't exist... Skip copy..."
            debuglog -Message "[DEBUG] Lobby $LobbyNumber did not passed copy | Location - From: $From - Destination: $To"
        }
    } else {
        debuglog -Message "[DEBUG] Lobby $LobbyNumber did not passed copy | Location - From: $From - Destination: $To"
    }
    
}

# function copyFiles {
#     param (
#         [boolean]$MultipleLobby = $true,
#         [string[]]$PluginList,
#         [string]$FinalFrom,
#         [string]$FinalDestination,
#         [int]$LobbyNumber
#     )

#     for ($PluginInt = 0; $PluginInt -lt $PluginList.Count; $PluginInt++) {
#         [string]$PluginsName = $PluginList[$PluginInt]

#         Write-Host
#         Write-Host "------------------------ [ $PluginsName ] ------------------------"

#         if ($MultipleLobby) {
#             for ($LobbyInt = 0; $LobbyInt -lt $LobbyAmount + 1; $LobbyInt++) {
#                 if ( $LobbyInt -ne 0 -and "$FinalFrom" -ne "$FinalDestination") {
#                     Write-Host

#                     if (Test-Path -Path $FinalDestination) {
#                         deleteItem -Location $FinalDestination
#                         Write-Host "Deleting Lobby [$LobbyInt] exist $PluginsName files..."

#                         debuglog -Message "[DEBUG] » Lobby $LobbyInt passed remove | Location » From: $FinalFrom - Destination: $FinalDestination"
#                     } else {
#                         debuglog -Message "[DEBUG] » Lobby $LobbyInt did not passed | Location » From: $FinalFrom - Destination: $FinalDestination"
#                     }

#                     if ("$FinalDestination" -ne "$FinalFrom") {
#                         if (Test-Path -Path $FinalFrom) {
#                             copyItem -From $FinalFrom -To $FinalDestination
#                             Write-Host "Copying $PluginsName to Lobby [$LobbyInt]"
#                         } else {
#                             Write-Host "Copying $PluginsName to Lobby [$LobbyInt], The file doesn't exist... Skipping..."
#                             debuglog -Message "[DEBUG] » Lobby $LobbyInt did not passed copy | Location » From: $FinalFrom - Destination: $FinalDestination"
#                         }
#                     } else {
#                         debuglog -Message "[DEBUG] » Lobby $LobbyInt did not passed copy | Location » From: $FinalFrom - Destination: $FinalDestination"
#                     }
#                 }
#             }
#         } else {
            
#         }
#     }
    
# }

function copyItem {
    param (
        [string]$From,
        [string]$To
    )
    Copy-Item -Force -Path "$From" -Destination "$To" -Recurse
}

function deleteItem {
    param (
        [string]$Location
    )
    Remove-Item -Path "$Location" -Recurse -Force 
}

# function copyFiles {
#     param (
#         [string[]]$FilesList,
#         [int]$LobbyAmount
#     )

#     for ($FilesInt = 0; $FilesInt -lt $FilesList.Count; $FilesInt++) {
#         [string]$FilesName = $FilesList[$FilesInt]

#         Write-Host
#         Write-Host "------------------------ [ $FilesName ] ------------------------"


#         for ($LobbyInt = 0; $LobbyInt -lt $LobbyAmount + 1; $LobbyInt++) {

#             [string]$FinalDestination = "$Destination$LobbyInt/$FilesName"
#             [string]$FinalFrom = "$FromFilesLocation$FilesName"
            
#             if ( $LobbyInt -ne 0 -and "$FinalFrom" -ne "$FinalDestination") {
#                 Write-Host
#                 if (Test-Path -Path $FinalDestination) {
#                     deleteItem -Location $FinalDestination 
#                     Write-Host "Deleting Lobby [$LobbyInt] exist $FilesName files..."

#                     debuglog -Message "[DEBUG] » Lobby $LobbyInt passed remove | Location » From: $FinalFrom - Destination: $FinalDestination"
#                 } else {
#                     debuglog -Message "[DEBUG] » Lobby $LobbyInt did not passed | Location » From: $FinalFrom - Destination: $FinalDestination"
#                 }

#                 if ("$FinalDestination" -ne "$FinalFrom") {
#                     if (Test-Path -Path $FinalFrom) {
#                         copyItem -From $FinalFrom -To $FinalDestination
#                         Write-Host "Copying $FilesName to Lobby [$LobbyInt]"
#                     } else {
#                         Write-Host "Copying $FilesName to Lobby [$LobbyInt], The file doesn't exist... Skipping..."
#                         debuglog -Message "[DEBUG] » Lobby $LobbyInt did not passed copy | Location » From: $FinalFrom - Destination: $FinalDestination"
#                     }
#                 } else {
#                     debuglog -Message "[DEBUG] » Lobby $LobbyInt did not passed copy | Location » From: $FinalFrom - Destination: $FinalDestination"
#                 }
#             }
#         }
#     }

# }

function debuglog {
    param (
        [string]$Message
    )
    
    if ($DebugMode) {
        Write-Host "$Message"
    }
}

function printTitle {
    param (
        [string]$Title
    )
    Write-Host
    if ($Title -eq "") {
        Write-Host "=================================================="
    } else {
        Write-Host "========================= $Title ========================"
    }
    Write-Host
}

Clear-Host
selectMode
pause