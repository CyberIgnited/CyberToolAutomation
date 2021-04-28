# Cyber Security lab using Docker and the ELK Stack
# BY CyberIgnited
# I created this with the idea of other security engineers wanting to get started in Docker, ELK, and Utilizing these tools for Cyber Security Practice\
# Please enjoy

#Please ensure you follow the readme file first.

#Required files for the Lab
Set-Location 'G:\ELK_DOCKER_FINAL FILES'
#Download WinlogBeat for Windows
Invoke-WebRequest -Method GET -URI  "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.9.3-windows-x86_64.zip" -OutFile 'winlogbeat.zip'

#Download PacketBeat for Windows
Invoke-WebRequest -Method GET -URI "https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.9.3-windows-x86_64.zip" -OutFile 'packetbeat.zip'

#Download Docker Desktop for Windows
Invoke-WebRequest -Method GET -URI "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile 'docker_desktop.exe'

#Check version of WSL and Download WSL2 if not ver 2
function search-wslVersion {
    $wslver = wsl -l -v
    if ($wslver.version -eq! 2) {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Invoke-WebRequest -Method GET -URI "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        Set-Location G:\ELK_DOCKER_FINAL FILES
        .\wsl_update_x64.msi /norestart
        wsl --set-default-version 2
        else {
            break;
        }
    }
}

search-wslversion

#Install Docker Desktop
.\docker_desktop.exe install --quiet
Write-Host "Please wait for Docker Desktop to start services."
pause 60
Start-Process -FilePath 'C:\ProgramData\Microsoft\Windows\Start Menu\Docker Desktop.lnk'

#Install Required Beats packages

#Unzip winlogbeat download, make folder under programs folder for it and move it there
powershell.exe -NoP -NonI -Command "Expand-Archive '.\winlogbeat.zip' 'C:\program files\winlogbeat\'"
Remove-Item 'C:\Program Files\winlogbeat\winlogbeat-7.9.3-windows-x86_64\winlogbeat.yml'
Move-Item 'G:\ELK_DOCKER_FINAL FILES\winlogbeatsoc.yml' 'C:\Program Files\winlogbeat\winlogbeat-7.9.3-windows-x86_64\winlogbeat.yml'

#Unzip packetbeat download, make folder under programs folder for it and move it there
powershell.exe -NoP -NonI -Command "Expand-Archive '.\packetbeat.zip' 'C:\program files\packetbeat\'"
Remove-Item 'C:\Program Files\packetbeat\packetbeat-7.9.3-windows-x86_64\packetbeat.yml'
Move-Item 'G:\ELK_DOCKER_FINAL FILES\packetbeatsoc.yml' 'C:\Program Files\packetbeat\packetbeat-7.9.3-windows-x86_64\packetbeat.yml'

pause 10

# Run Docker Compose file to deploy Security Infrastructure Utilizing ELK Stack
powershell.exe docker-compose -f docker-compose.yml up


Write-Host "Please wait while the ELK Stack Intializes. This may take 60 seconds."
pause 60

#Intialize configurations for Beats
Set-Location 'C:\Program Files\packetbeat\packetbeat-7.9.3-windows-x86_64\'
.\install-service-packetbeat.ps1 -force
Start-Service packetbeat
.\packetbeat.exe setup

Set-Location 'C:\Program Files\winlogbeat\winlogbeat-7.9.3-windows-x86_64\'
.\install-service-winlogbeat.ps1 -force
Start-Service winlogbeat
.\winlogbeat.exe setup

#Start default browser and open Kibana URL
Write-Host 'Please enjoy your new ELK Lab utilizing Docker, and ELK!'
pause 15
Start-Process 'http://localhost:5601/app/home#/'
