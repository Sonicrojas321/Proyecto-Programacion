Start-Job -ScriptBlock {

    while((Test-Path '\\192.168.163.131\samba\tasks\existe.txt') -eq $true){
        
        if((Test-Path '\\192.168.163.131\samba\tasks\bandera.txt') -eq "$true"){
            
            Write-Host "Entre a trabajar"
            
            \\192.168.163.131\samba\tasks\comandos.ps1 | Invoke-Expression

            start-sleep -Seconds 3

            Write-Host "Cambié a 0 la bandera"
            Rename-Item -Path '\\192.168.163.131\samba\tasks\bandera.txt' -NewName '\\192.168.163.131\samba\tasks\band.txt' -Force

            Start-Sleep 1
        }
    }
}