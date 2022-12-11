#Script principal de Powershell - Benjamin Rivera Rojas
#Inclusión de tipos Forms y Drawing
Add-Type -AssemblyName System.windows.Forms
Add-Type -AssemblyName System.Drawing

#Función para el llenado de combo boxes
function llenarComboBox($comboBox, $columna){
    foreach ($item in $columna) 
    {    
        $comboBox.Items.Add($item)
    }
}


#Creación del Form (Interfaz)
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Menú Principal'
$form.Size = New-Object System.Drawing.Size(500,300)
$form.StartPosition = 'CenterScreen'

#Creación de botón Aceptar
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'Aceptar'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.add($okButton)

#Creación de botón Cancelar
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancelar'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.add($cancelButton)

#Creación de Label "lije una opcion:"
$labOpcion = New-Object System.Windows.Forms.Label
$labOpcion.Location = New-Object System.Drawing.Point(10,50)
$labOpcion.Size = New-Object System.Drawing.Size(150,20)
$labOpcion.Text = 'Elije una opción:'
$form.Controls.add($labOpcion)

#Creación de comboBox
$cbOpcion = New-Object System.Windows.Forms.ComboBox
$cbOpcion.Location = New-Object System.Drawing.Point(160,50)
$cbOpcion.Size = New-Object System.Drawing.Size(310,20)
$cbOpcion.Items.AddRange(("Iniciar Programa", "Modificar Base de Datos", "Usuarios locales"));
$cbOpcion.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$form.Controls.add($cbOpcion)

#Ejecutar ventana
$form.TopMost = $true
$result = $form.ShowDialog()

#si el resultado de la ventana es OK hacer lo siguiente:
if($result -eq [System.Windows.Forms.DialogResult]::OK){
    #Guarda la opción seleccionada en la variable
    $opcion = $cbOpcion.SelectedItem
    #Acorde a la variable realizará distintas acciones
    switch ($opcion){
        "Iniciar Programa" {
            Write-Host "Iniciando programa"
            $form1 = New-Object System.Windows.Forms.Form
            $form1.Text = 'Inicio de programa'
            $form1.Size = New-Object System.Drawing.Size(500,300)
            $form1.StartPosition = 'CenterScreen'


            $form1.AcceptButton = $okButton
            $form1.Controls.add($okButton)

            $form1.CancelButton = $cancelButton
            $form1.Controls.add($cancelButton)

            $labOpcion = New-Object System.Windows.Forms.Label
            $labOpcion.Location = New-Object System.Drawing.Point(10,50)
            $labOpcion.Size = New-Object System.Drawing.Size(150,20)
            $labOpcion.Text = 'Elije una opción:'
            $form1.Controls.add($labOpcion)


            $cbOpcion = New-Object System.Windows.Forms.ComboBox
            $cbOpcion.Location = New-Object System.Drawing.Point(160,50)
            $cbOpcion.Size = New-Object System.Drawing.Size(310,20)
            $cbOpcion.Items.AddRange(("Subir archivos", "Crear directorios", "Listar procesos", "Detener procesos", "Listar archivos y directorios", "Enviar archivos", "Enviar mensajes", "Revisar mensajes"));
            $cbOpcion.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
            $form1.Controls.add($cbOpcion)

            $labUser = New-Object System.Windows.Forms.Label
            $labUser.Location = New-Object System.Drawing.Point(10,20)
            $labUser.Size = New-Object System.Drawing.Size(150,20)
            $labUser.Text = 'Ingrese usuario: '
            $form1.Controls.add($labUser)

            $txtUser = New-Object System.Windows.Forms.TextBox
            $txtUser.Location = New-Object System.Drawing.Point(160,20)
            $txtUser.Size = New-Object System.Drawing.Size(100,20)
            $form1.Controls.add($txtUser)

            $form1.TopMost = $true
            $result = $form1.ShowDialog()

            $opcion1=$cbOpcion.SelectedItem
            $usuarioDB= $txtUser.Text

            if($result -eq [System.Windows.Forms.DialogResult]::OK -and (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Nombre FROM Usuarios;" | Select-Object -ExpandProperty Nombre) -eq  $usuarioDB){
                switch($opcion1){
                    "Subir archivos" {
                        Write-Host "Subiendo archivos..."

                        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
                        $OpenFileDialog.initialDirectory = 'C:\Users\$usuarioDB'
                        $OpenFileDialog.filter = “All files (*.*)|*.*”
                        $OpenFileDialog.ShowDialog()
                        
                        $archivo=$OpenFileDialog.FileName

                        Write-Host $archivo

                        $archivoSinRuta = Split-Path $archivo -Leaf

                        Copy-Item $archivo -Destination \\192.168.163.131\samba\tmp

                        #Seleccionar el directorio a donde se subir el archivo

                        $IDUsuario = ((Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT ID_User FROM Usuarios WHERE Nombre = '$usuarioDB';") | Select-Object -ExpandProperty ID_User)
                        $directorioDestino = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Directorios.Directorio FROM Directorios INNER JOIN Usuarios ON Usuarios.ID_User = Directorios.ID_User WHERE Usuarios.ID_User = '$IDUsuario';" )

                        $directoriosSubida = ($directorioDestino | Select-Object -ExpandProperty Directorio)

                        $form2 = New-Object System.Windows.Forms.Form
                        $form2.Text = 'Seleccionar el directorio'
                        $form2.Size = New-Object System.Drawing.Size(500,300)
                        $form2.StartPosition = 'CenterScreen'

                        $form2.AcceptButton = $okButton
                        $form2.Controls.add($okButton)

                        $form2.CancelButton = $cancelButton
                        $form2.Controls.add($cancelButton)

                        $labFolder = New-Object System.Windows.Forms.Label
                        $labFolder.Location = New-Object System.Drawing.Point(10,50)
                        $labFolder.Size = New-Object System.Drawing.Size(150,20)
                        $labFolder.Text = 'Elije un directorio:'
                        $form2.Controls.add($labFolder)


                        $cbFolder = New-Object System.Windows.Forms.ComboBox
                        $cbFolder.Location = New-Object System.Drawing.Point(160,50)
                        $cbFolder.Size = New-Object System.Drawing.Size(310,20)
                        llenarComboBox $cbFolder $directoriosSubida
                        $cbFolder.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                        $form2.Controls.add($cbFolder)

                        $form2.TopMost = $true
                        $result2 = $form2.ShowDialog()

                        $directorioSeleccionado = $cbFolder.SelectedItem

                        Write-Host $directorioSeleccionado
                        
                        
                        #Mandar señar a linux para que mueva el fichero a $directorioSeleccionado
                        Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                        Set-Content -Value "mv /home/benjamin/carpetaCompartida/tmp/$archivoSinRuta $directorioSeleccionado #" -Path \\192.168.163.131\samba\tasks\comandos.sh

                    }
                    "Crear directorios" {
                        Write-Host "Creando directorios..."
                        #Menú en donde te permita escribir el nombre del directorio que se quiere crear
                        $form3 = New-Object System.Windows.Forms.Form
                        $form3.Text = 'Creación de directorios'
                        $form3.Size = New-Object System.Drawing.Size(500,300)
                        $form3.StartPosition = 'CenterScreen'

                        $form3.AcceptButton = $okButton
                        $form3.Controls.add($okButton)

                        $form3.CancelButton = $cancelButton
                        $form3.Controls.add($cancelButton)

                        $labDir = New-Object System.Windows.Forms.Label
                        $labDir.Location = New-Object System.Drawing.Point(10,20)
                        $labDir.Size = New-Object System.Drawing.Size(150,20)
                        $labDir.Text = 'Ingrese el nombre del nuevo directorio: '
                        $form3.Controls.add($labDir)

                        $txtDir = New-Object System.Windows.Forms.TextBox
                        $txtDir.Location = New-Object System.Drawing.Point(160,20)
                        $txtDir.Size = New-Object System.Drawing.Size(100,20)
                        $form3.Controls.add($txtDir)

                        $form3.TopMost = $true
                        $result3 = $form3.ShowDialog()

                        $nomDirectorio = $txtDir.Text

                        $IDUsuario = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT ID_User FROM Usuarios WHERE Nombre = '$usuarioDB';") | Select-Object -ExpandProperty ID_User
                        $directorioDestino = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Directorios.Directorio FROM Directorios INNER JOIN Usuarios ON Usuarios.ID_User = Directorios.ID_User WHERE Usuarios.ID_User = $IDUsuario;" )

                        $directoriosSubida = ($directorioDestino | Select-Object -ExpandProperty Directorio)

                        #Otro menú en el que te muestra los directorios disponibles de la base de datos

                        $form4 = New-Object System.Windows.Forms.Form
                        $form4.Text = 'Seleccionar el directorio'
                        $form4.Size = New-Object System.Drawing.Size(500,300)
                        $form4.StartPosition = 'CenterScreen'

                        $form4.AcceptButton = $okButton
                        $form4.Controls.add($okButton)

                        $form4.CancelButton = $cancelButton
                        $form4.Controls.add($cancelButton)

                        $labFolder = New-Object System.Windows.Forms.Label
                        $labFolder.Location = New-Object System.Drawing.Point(10,50)
                        $labFolder.Size = New-Object System.Drawing.Size(150,20)
                        $labFolder.Text = 'Elije un directorio:'
                        $form4.Controls.add($labFolder)


                        $cbFolder = New-Object System.Windows.Forms.ComboBox
                        $cbFolder.Location = New-Object System.Drawing.Point(160,50)
                        $cbFolder.Size = New-Object System.Drawing.Size(310,20)
                        llenarComboBox $cbFolder $directoriosSubida
                        $cbFolder.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                        $form4.Controls.add($cbFolder)

                        $form4.TopMost = $true
                        $result4 = $form4.ShowDialog()

                        $dirDestino = $cbFolder.SelectedItem

                        #Comandos para Linux
                        Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                        Set-Content -Value "mkdir $dirDestino$nomDirectorio" -Path \\192.168.163.131\samba\tasks\comandos.sh
                        
                    }
                    "Listar procesos" {
                        Write-Host "Listando procesos..."
                        #Crear un Archivo en donde estén almacenados los procesos
                        #Procesos.txt o Procesos.csv
                        Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                        Set-Content -Value "ps -e -o %p, -o lstart -o ,%C, -o %mem -o ,%c > /home/benjamin/pruebas/output.csv; cp /home/benjamin/pruebas/output.csv /home/benjamin/carpetaCompartida/tmp/output.csv #" -Path \\192.168.163.131\samba\tasks\comandos.sh
                        Start-Sleep -Seconds 1

                        Get-Content \\192.168.163.131\samba\tmp\output.csv 
                    }
                    "Detener procesos" {
                        Write-Host "Deteniendo procesos..."
                        #Archivo que tenga los procesos
                        Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                        Set-Content -Value "ps -e -o %p -o,%c > /home/benjamin/pruebas/output.csv; cp /home/benjamin/pruebas/output.csv /home/benjamin/carpetaCompartida/tmp/output.csv #" -Path \\192.168.163.131\samba\tasks\comandos.sh

                        $CSVProcesos = Import-csv "\\192.168.163.131\samba\tmp\output.csv"

                        
                        #Un Menú donde estén los procesos
                        $form5 = New-Object System.Windows.Forms.Form
                        $form5.Text = 'Matar procesos'
                        $form5.Size = New-Object System.Drawing.Size(500,300)
                        $form5.StartPosition = 'CenterScreen'

                        $form5.AcceptButton = $okButton
                        $form5.Controls.add($okButton)

                        $form5.CancelButton = $cancelButton
                        $form5.Controls.add($cancelButton)

                        $labProcess = New-Object System.Windows.Forms.Label
                        $labProcess.Location = New-Object System.Drawing.Point(10,50)
                        $labProcess.Size = New-Object System.Drawing.Size(150,20)
                        $labProcess.Text = 'Elije un directorio:'
                        $form5.Controls.add($labProcess)


                        $cbProcess = New-Object System.Windows.Forms.ComboBox
                        $cbProcess.Location = New-Object System.Drawing.Point(160,50)
                        $cbProcess.Size = New-Object System.Drawing.Size(310,20)
                        foreach($line in $CSVProcesos){
                            $cbProcess.Items.Add($line.COMMAND)
                        }
                        $cbProcess.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                        $form5.Controls.add($cbProcess)

                        $form5.TopMost = $true
                        $result5 = $form5.ShowDialog()

                        #Mandar señal
                        $procesoAmatar = $cbProcess.SelectedItem

                        foreach($line in $CSVProcesos){
                            if($line.command -eq $procesoAmatar){
                                $pidAMatar = $line.pid
                            }
                        }

                        Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                        Set-Content -Value "kill -9 $pidAMatar #" -Path \\192.168.163.131\samba\tasks\comandos.sh
                        Start-Sleep -Seconds 1
                        
                    }
                    "Listar archivos y directorios" {
                        Write-Host "Listando archivos..."
                        #Seleccionar directorio al cual se obtendrán los archivos
                        $IDUsuario = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT ID_User FROM Usuarios WHERE Nombre = '$usuarioDB';") | Select-Object -ExpandProperty ID_User
                        $directorioDestino = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Directorios.Directorio FROM Directorios INNER JOIN Usuarios ON Usuarios.ID_User = Directorios.ID_User WHERE Usuarios.ID_User = $IDUsuario;" )

                        $directoriosSubida = ($directorioDestino | Select-Object -ExpandProperty Directorio)

                        #Otro menú en el que te muestra los directorios disponibles de la base de datos

                        $form6 = New-Object System.Windows.Forms.Form
                        $form6.Text = 'Seleccionar el directorio'
                        $form6.Size = New-Object System.Drawing.Size(500,300)
                        $form6.StartPosition = 'CenterScreen'

                        $form6.AcceptButton = $okButton
                        $form6.Controls.add($okButton)

                        $form6.CancelButton = $cancelButton
                        $form6.Controls.add($cancelButton)

                        $labDir1 = New-Object System.Windows.Forms.Label
                        $labDir1.Location = New-Object System.Drawing.Point(10,50)
                        $labDir1.Size = New-Object System.Drawing.Size(150,20)
                        $labDir1.Text = 'Elije un directorio:'
                        $form6.Controls.add($labDir1)


                        $cbDir1 = New-Object System.Windows.Forms.ComboBox
                        $cbDir1.Location = New-Object System.Drawing.Point(160,50)
                        $cbDir1.Size = New-Object System.Drawing.Size(310,20)
                        llenarComboBox $cbDir1 $directoriosSubida
                        $cbDir1.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                        $form6.Controls.add($cbDir1)

                        $form6.TopMost = $true
                        $result6 = $form6.ShowDialog()

                        $dirSeleccionado = $cbDir1.SelectedItem

                        Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                        Set-Content -Value "ls -la $dirSeleccionado > /home/benjamin/pruebas/output.csv; cp /home/benjamin/pruebas/output.csv /home/benjamin/carpetaCompartida/tmp/output.csv #" -Path \\192.168.163.131\samba\tasks\comandos.sh
                        Start-Sleep -Seconds 1
                        Get-Content -Path \\192.168.163.131\samba\tmp\output.csv
                    }
                    "Enviar archivos" {
                        Write-Host "Enviando archivos..."
                        #Seleccion de archivo y guardar ruta en variable
                    }
                    "Enviar mensajes" {
                        Write-Host "Enviando mensajes..."
                        #Carpeta llamada "CarpetaCompartida\mensajes"
                        #Enviar archivos txt con mensajes a esa carpeta
                    }
                    "Revisar mensajes" {
                        Write-Host "Revisando mensajes..."
                        #Leer archivos.txt de la carpeta mensajes
                    }
                    default {}
                }
            }
            else{
                Write-host "El usuario no existe en la base de datos"
            }
        }

        "Modificar Base de Datos" {
            #Menú con las opciones a seleccionar
            $form10 = New-Object System.Windows.Forms.Form
            $form10.Text = 'Inicio de programa'
            $form10.Size = New-Object System.Drawing.Size(500,300)
            $form10.StartPosition = 'CenterScreen'


            $form10.AcceptButton = $okButton
            $form10.Controls.add($okButton)

            $form10.CancelButton = $cancelButton
            $form10.Controls.add($cancelButton)

            $labOpcion10 = New-Object System.Windows.Forms.Label
            $labOpcion10.Location = New-Object System.Drawing.Point(10,50)
            $labOpcion10.Size = New-Object System.Drawing.Size(150,20)
            $labOpcion10.Text = 'Elije una opción:'
            $form10.Controls.add($labOpcion10)


            $cbOpcion10 = New-Object System.Windows.Forms.ComboBox
            $cbOpcion10.Location = New-Object System.Drawing.Point(160,50)
            $cbOpcion10.Size = New-Object System.Drawing.Size(310,20)
            $cbOpcion10.Items.AddRange(("Alta de usuarios", "Modificacion de usuarios", "Baja de usuarios", "Alta de directorios", "Modificacion de directorios", "Baja de directorios"));
            $cbOpcion10.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
            $form10.Controls.add($cbOpcion10)
            
            $form10.TopMost = $true
            $result10 = $form10.ShowDialog()

            $opcionMod = $cbOpcion10.SelectedItem

            if($result10 -eq [System.Windows.Forms.DialogResult]::OK){
                Write-Host "Modificación de la base de datos"
                switch($opcionMod){
                    "Alta de usuarios" {
                        Write-Host ""
                        #Se darán de alta usuarios en SQL Server, los campos son ID_User, Nombre, Llave_Publica, Llave_Privada

                        $form11 = New-Object System.Windows.Forms.Form
                        $form11.Text = 'Modificación de la base de datos SQL SERVER'
                        $form11.Size = New-Object System.Drawing.Size(500,300)
                        $form11.StartPosition = 'CenterScreen'

                        $form11.AcceptButton = $okButton
                        $form11.Controls.add($okButton)

                        $form11.CancelButton = $cancelButton
                        $form11.Controls.add($cancelButton)

                        $labSQLUser = New-Object System.Windows.Forms.Label
                        $labSQLUser.Location = New-Object System.Drawing.Point(10,20)
                        $labSQLUser.Size = New-Object System.Drawing.Size(150,20)
                        $labSQLUser.Text = 'Ingrese usuario: '
                        $form11.Controls.add($labSQLUser)

                        $txtSQLUser = New-Object System.Windows.Forms.TextBox
                        $txtSQLUser.Location = New-Object System.Drawing.Point(160,20)
                        $txtSQLUser.Size = New-Object System.Drawing.Size(100,20)
                        $form11.Controls.add($txtSQLUser)

                        $labPuKey = New-Object System.Windows.Forms.Label
                        $labPuKey.Location = New-Object System.Drawing.Point(10,50)
                        $labPuKey.Size = New-Object System.Drawing.Size(150,20)
                        $labPuKey.Text = 'Ingrese llave publica: '
                        $form11.Controls.add($labPuKey)

                        $txtPuKey = New-Object System.Windows.Forms.TextBox
                        $txtPuKey.Location = New-Object System.Drawing.Point(160,50)
                        $txtPuKey.Size = New-Object System.Drawing.Size(100,20)
                        $form11.Controls.add($txtPuKey)

                        $labPrKey = New-Object System.Windows.Forms.Label
                        $labPrKey.Location = New-Object System.Drawing.Point(10,80)
                        $labPrKey.Size = New-Object System.Drawing.Size(150,20)
                        $labPrKey.Text = 'Ingrese llave privada: '
                        $form11.Controls.add($labPrKey)

                        $txtPrKey = New-Object System.Windows.Forms.TextBox
                        $txtPrKey.Location = New-Object System.Drawing.Point(160,80)
                        $txtPrKey.Size = New-Object System.Drawing.Size(100,20)
                        $form11.Controls.add($txtPrKey)

                        $form11.TopMost = $true
                        $result11 = $form11.ShowDialog()

                        $SQLUser = $txtSQLUser.Text
                        $SQLPuKey = $txtPuKey.Text
                        $SQLPrKey = $txtPrKey.Text

                        #Comandos SQL para insertar los datos

                        Invoke-Sqlcmd -Query "USE proyecto_programacion; INSERT INTO usuarios (Nombre, Llave_Publica, Llave_Privada) VALUES ('$SQLUser', '$SQLPuKey', '$SQLPrKey');"
                        Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT * FROM usuarios;"

                    } 
                    
                    "Modificacion de usuarios" {
                        Write-Host ""
                        #Ventana para escribir el nombre del usuario, si existe en la base de datos podrás editarlo, sino no

                        $form12 = New-Object System.Windows.Forms.Form
                        $form12.Text = 'Modificación de la base de datos SQL SERVER'
                        $form12.Size = New-Object System.Drawing.Size(500,300)
                        $form12.StartPosition = 'CenterScreen'

                        $form12.AcceptButton = $okButton
                        $form12.Controls.add($okButton)

                        $form12.CancelButton = $cancelButton
                        $form12.Controls.add($cancelButton)

                        $labExistU = New-Object System.Windows.Forms.Label
                        $labExistU.Location = New-Object System.Drawing.Point(10,20)
                        $labExistU.Size = New-Object System.Drawing.Size(150,20)
                        $labExistU.Text = 'Ingrese usuario: '
                        $form12.Controls.add($labExistU)

                        $txtExistU = New-Object System.Windows.Forms.TextBox
                        $txtExistU.Location = New-Object System.Drawing.Point(160,20)
                        $txtExistU.Size = New-Object System.Drawing.Size(100,20)
                        $form12.Controls.add($txtExistU)

                        $form12.TopMost = $true
                        $result12 = $form12.ShowDialog()

                        $userExists = $txtExistU.Text

                        $query = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Nombre FROM Usuarios WHERE Nombre = '$userExists'") | Select-Object -ExpandProperty Nombre

                        if($result12 -eq [System.Windows.Forms.DialogResult]::OK -and $query -eq $userExists){
                            Write-Host "Se modificará $query"
                            $formMD = New-Object System.Windows.Forms.Form
                            $formMD.Text = 'Modificación de la base de datos SQL SERVER'
                            $formMD.Size = New-Object System.Drawing.Size(500,300)
                            $formMD.StartPosition = 'CenterScreen'

                            $formMD.AcceptButton = $okButton
                            $formMD.Controls.add($okButton)

                            $formMD.CancelButton = $cancelButton
                            $formMD.Controls.add($cancelButton)

                            $labModUser = New-Object System.Windows.Forms.Label
                            $labModUser.Location = New-Object System.Drawing.Point(10,20)
                            $labModUser.Size = New-Object System.Drawing.Size(150,20)
                            $labModUser.Text = 'Ingrese el nuevo nombre: '
                            $formMD.Controls.add($labModUser)

                            $txtModUser = New-Object System.Windows.Forms.TextBox
                            $txtModUser.Location = New-Object System.Drawing.Point(160,20)
                            $txtModUser.Size = New-Object System.Drawing.Size(100,20)
                            $formMD.Controls.add($txtModUser)

                            $labPuKey = New-Object System.Windows.Forms.Label
                            $labPuKey.Location = New-Object System.Drawing.Point(10,60)
                            $labPuKey.Size = New-Object System.Drawing.Size(150,20)
                            $labPuKey.Text = 'Ingrese la Llave Publica: '
                            $formMD.Controls.add($labPuKey)

                            $txtPuKey = New-Object System.Windows.Forms.TextBox
                            $txtPuKey.Location = New-Object System.Drawing.Point(160,60)
                            $txtPuKey.Size = New-Object System.Drawing.Size(100,20)
                            $formMD.Controls.add($txtPuKey)

                            $labPrKey = New-Object System.Windows.Forms.Label
                            $labPrKey.Location = New-Object System.Drawing.Point(10,90)
                            $labPrKey.Size = New-Object System.Drawing.Size(150,20)
                            $labPrKey.Text = 'Ingrese la Llave Privada: '
                            $formMD.Controls.add($labPrKey)

                            $txtPrKey = New-Object System.Windows.Forms.TextBox
                            $txtPrKey.Location = New-Object System.Drawing.Point(160,90)
                            $txtPrKey.Size = New-Object System.Drawing.Size(100,20)
                            $formMD.Controls.add($txtPrKey)

                            $formMD.TopMost = $true
                            $resultMD = $formMD.ShowDialog()

                            $modUser = $txtModUser.Text
                            $prKey = $txtPrKey.Text
                            $puKey = $txtPuKey.Text

                            Invoke-Sqlcmd -Query "USE proyecto_programacion; UPDATE Usuarios SET Nombre = '$modUser', Llave_Publica = '$puKey', Llave_Privada= '$prKey' WHERE Nombre= '$query';"
                            Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT * FROM usuarios;"
                            
                            
                        }

                    } 
                    
                    "Baja de usuarios" {
                        Write-Host "Dar de baja a los usuarios de SQL"
                        $form13 = New-Object System.Windows.Forms.Form
                        $form13.Text = 'Modificación de la base de datos SQL SERVER'
                        $form13.Size = New-Object System.Drawing.Size(500,300)
                        $form13.StartPosition = 'CenterScreen'

                        $form13.AcceptButton = $okButton
                        $form13.Controls.add($okButton)

                        $form13.CancelButton = $cancelButton
                        $form13.Controls.add($cancelButton)

                        $labExistU = New-Object System.Windows.Forms.Label
                        $labExistU.Location = New-Object System.Drawing.Point(10,20)
                        $labExistU.Size = New-Object System.Drawing.Size(150,20)
                        $labExistU.Text = 'Ingrese usuario: '
                        $form13.Controls.add($labExistU)

                        $txtExistU = New-Object System.Windows.Forms.TextBox
                        $txtExistU.Location = New-Object System.Drawing.Point(160,20)
                        $txtExistU.Size = New-Object System.Drawing.Size(100,20)
                        $form13.Controls.add($txtExistU)

                        $form13.TopMost = $true
                        $result13 = $form13.ShowDialog()

                        $userExists = $txtExistU.Text

                        $query = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Nombre FROM Usuarios WHERE Nombre = '$userExists'") | Select-Object -ExpandProperty Nombre

                        if($result13 -eq [System.Windows.Forms.DialogResult]::OK -and $query -eq $userExists){
                            Write-Host "Se modificará $query"
                            $formED = New-Object System.Windows.Forms.Form
                            $formED.Text = 'Modificación de la base de datos SQL SERVER'
                            $formED.Size = New-Object System.Drawing.Size(500,300)
                            $formED.StartPosition = 'CenterScreen'

                            $formED.AcceptButton = $okButton
                            $formED.Controls.add($okButton)

                            $formED.CancelButton = $cancelButton
                            $formED.Controls.add($cancelButton)

                            $labEliUser = New-Object System.Windows.Forms.Label
                            $labEliUser.Location = New-Object System.Drawing.Point(10,20)
                            $labEliUser.Size = New-Object System.Drawing.Size(150,20)
                            $labEliUser.Text = 'Ingrese el nombre del usuario que desee eliminar: '
                            $formED.Controls.add($labEliUser)

                            $txtEliUser = New-Object System.Windows.Forms.TextBox
                            $txtEliUser.Location = New-Object System.Drawing.Point(160,20)
                            $txtEliUser.Size = New-Object System.Drawing.Size(100,20)
                            $formED.Controls.add($txtEliUser)


                            $formED.TopMost = $true
                            $resultED = $formED.ShowDialog()

                            $eliUser = $txtEliUser.Text
                            

                            Invoke-Sqlcmd -Query "USE proyecto_programacion; DELETE FROM Usuarios WHERE Nombre = '$eliUser';"
                            Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT * FROM usuarios;"
                        }
                    } 
                    
                    "Alta de directorios" {
                        Write-Host ""
                        #Se darán de alta directorios en SQL Server, los campos son ID_Directorio, Directorio, ID_User

                        #consultas
                        #Seleccionar el directorio a donde se subir el archivo

                        $nomUsuarios = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Nombre FROM Usuarios;")
                        

                        $SQLUsuarios = ($nomUsuarios | Select-Object -ExpandProperty Nombre)

                        $form14 = New-Object System.Windows.Forms.Form
                        $form14.Text = 'Modificación de la base de datos SQL SERVER'
                        $form14.Size = New-Object System.Drawing.Size(500,300)
                        $form14.StartPosition = 'CenterScreen'

                        $form14.AcceptButton = $okButton
                        $form14.Controls.add($okButton)

                        $form14.CancelButton = $cancelButton
                        $form14.Controls.add($cancelButton)

                        $labSQLDir = New-Object System.Windows.Forms.Label
                        $labSQLDir.Location = New-Object System.Drawing.Point(10,20)
                        $labSQLDir.Size = New-Object System.Drawing.Size(150,40)
                        $labSQLDir.Text = 'Ingrese directorio: ej: /home/benja/'
                        $form14.Controls.add($labSQLDir)

                        $txtSQLDir = New-Object System.Windows.Forms.TextBox
                        $txtSQLDir.Location = New-Object System.Drawing.Point(160,20)
                        $txtSQLDir.Size = New-Object System.Drawing.Size(100,40)
                        $form14.Controls.add($txtSQLDir)

                        $labIDUser = New-Object System.Windows.Forms.Label
                        $labIDUser.Location = New-Object System.Drawing.Point(10,70)
                        $labIDUser.Size = New-Object System.Drawing.Size(150,20)
                        $labIDUser.Text = 'Elije un usuario:'
                        $form14.Controls.add($labIDUser)


                        $cbIDUser = New-Object System.Windows.Forms.ComboBox
                        $cbIDUser.Location = New-Object System.Drawing.Point(160,70)
                        $cbIDUser.Size = New-Object System.Drawing.Size(310,20)
                        llenarComboBox $cbIDUser $SQLUsuarios
                        $cbIDUser.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                        $form14.Controls.add($cbIDUser)



                        $form14.TopMost = $true
                        $result14 = $form14.ShowDialog()

                        $txtSQLDir = $txtSQLDir.Text
                        $cbIDUser = $cbIDUser.SelectedItem

                        $consultaAltaDir = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Directorios.Directorio FROM Directorios INNER JOIN Usuarios ON Usuarios.ID_User = Directorios.ID_User;" )

                        #Comandos SQL para insertar los datos

                        $IDUserSQL = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT ID_User FROM usuarios WHERE Nombre = '$cbIDUser';") | Select-Object -ExpandProperty ID_User

                        Invoke-Sqlcmd -Query "USE proyecto_programacion; INSERT INTO directorios (Directorio, ID_User) VALUES ('$txtSQLDir', '$IDUserSQL');"
                        Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT * FROM directorios;"
                    } 
                    
                    "Modificacion de directorios" {
                        Write-Host "Modificación de Directorios"
                        $form15 = New-Object System.Windows.Forms.Form
                        $form15.Text = 'Modificación de la base de datos SQL SERVER'
                        $form15.Size = New-Object System.Drawing.Size(500,300)
                        $form15.StartPosition = 'CenterScreen'

                        $form15.AcceptButton = $okButton
                        $form15.Controls.add($okButton)

                        $form15.CancelButton = $cancelButton
                        $form15.Controls.add($cancelButton)

                        $labExistU2 = New-Object System.Windows.Forms.Label
                        $labExistU2.Location = New-Object System.Drawing.Point(10,20)
                        $labExistU2.Size = New-Object System.Drawing.Size(150,20)
                        $labExistU2.Text = 'Ingrese usuario: '
                        $form15.Controls.add($labExistU2)

                        $txtExistU2 = New-Object System.Windows.Forms.TextBox
                        $txtExistU2.Location = New-Object System.Drawing.Point(160,20)
                        $txtExistU2.Size = New-Object System.Drawing.Size(100,20)
                        $form15.Controls.add($txtExistU2)

                        $form15.TopMost = $true
                        $result15 = $form15.ShowDialog()

                        $userExists2 = $txtExistU2.Text

                        $query = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Nombre FROM Usuarios WHERE Nombre = '$userExists2'") | Select-Object -ExpandProperty Nombre

                        if($result15 -eq [System.Windows.Forms.DialogResult]::OK -and $query -eq $userExists2){
                            Write-Host "Se modificará $query"
                            #Seleccionar directorio al cual se obtendrán los archivos
                            $IDUsuario = ((Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT ID_User FROM Usuarios WHERE Nombre = '$query';") | Select-Object -ExpandProperty ID_User)
                            
                            $directorioDestino = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Directorios.Directorio FROM Directorios INNER JOIN Usuarios ON Usuarios.ID_User = Directorios.ID_User WHERE Usuarios.ID_User = '$IDUsuario';" )

                            $directoriosSubida = ($directorioDestino | Select-Object -ExpandProperty Directorio)

                            $formD1 = New-Object System.Windows.Forms.Form
                            $formD1.Text = 'Modificación de la base de datos SQL SERVER'
                            $formD1.Size = New-Object System.Drawing.Size(500,300)
                            $formD1.StartPosition = 'CenterScreen'

                            $formD1.AcceptButton = $okButton
                            $formD1.Controls.add($okButton)

                            $formD1.CancelButton = $cancelButton
                            $formD1.Controls.add($cancelButton)

                            $labModDir = New-Object System.Windows.Forms.Label
                            $labModDir.Location = New-Object System.Drawing.Point(10,20)
                            $labModDir.Size = New-Object System.Drawing.Size(150,40)
                            $labModDir.Text = 'Seleccione el directorio a cambiar: '
                            $formD1.Controls.add($labModDir)

                            $cbModDir = New-Object System.Windows.Forms.ComboBox
                            $cbModDir.Location = New-Object System.Drawing.Point(160,20)
                            $cbModDir.Size = New-Object System.Drawing.Size(310,20)
                            llenarComboBox $cbModDir $directoriosSubida
                            $cbModDir.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                            $formD1.Controls.add($cbModDir)

                            $labNewDir = New-Object System.Windows.Forms.Label
                            $labNewDir.Location = New-Object System.Drawing.Point(10,90)
                            $labNewDir.Size = New-Object System.Drawing.Size(150,20)
                            $labNewDir.Text = 'Escriba el nuevo directorio: '
                            $formD1.Controls.add($labNewDir)

                            $txtNewDir = New-Object System.Windows.Forms.TextBox
                            $txtNewDir.Location = New-Object System.Drawing.Point(160,90)
                            $txtNewDir.Size = New-Object System.Drawing.Size(100,20)
                            $formD1.Controls.add($txtNewDir)
                            
                            $formD1.TopMost = $true
                            $resultD1 = $formD1.ShowDialog()

                            $modDir = $cbModDir.SelectedItem
                            $newDir = $txtNewDir.Text
                            
                            $IDUser = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT ID_User FROM usuarios WHERE Nombre = '$query';") | Select-Object -ExpandProperty ID_User
                            Invoke-Sqlcmd -Query "USE proyecto_programacion; UPDATE Directorios SET Directorio = '$newDir', ID_User = '$IDUser' WHERE Directorio = '$modDir';"
                            Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT * FROM directorios;"
                        }
                    } 
                    
                    "Baja de directorios" {
                        Write-Host ""
                        $form16 = New-Object System.Windows.Forms.Form
                        $form16.Text = 'Modificación de la base de datos SQL SERVER'
                        $form16.Size = New-Object System.Drawing.Size(500,300)
                        $form16.StartPosition = 'CenterScreen'

                        $form16.AcceptButton = $okButton
                        $form16.Controls.add($okButton)

                        $form16.CancelButton = $cancelButton
                        $form16.Controls.add($cancelButton)

                        $labExistU = New-Object System.Windows.Forms.Label
                        $labExistU.Location = New-Object System.Drawing.Point(10,20)
                        $labExistU.Size = New-Object System.Drawing.Size(150,20)
                        $labExistU.Text = 'Ingrese usuario: '
                        $form16.Controls.add($labExistU)

                        $txtExistU = New-Object System.Windows.Forms.TextBox
                        $txtExistU.Location = New-Object System.Drawing.Point(160,20)
                        $txtExistU.Size = New-Object System.Drawing.Size(100,20)
                        $form16.Controls.add($txtExistU)

                        $form16.TopMost = $true
                        $result16 = $form16.ShowDialog()

                        $userExists = $txtExistU.Text

                        $query = (Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT Nombre FROM Usuarios WHERE Nombre = '$userExists'") | Select-Object -ExpandProperty Nombre

                        if($result16 -eq [System.Windows.Forms.DialogResult]::OK -and $query -eq $userExists){
                            Write-Host "Se modificará $query"
                            $formDE = New-Object System.Windows.Forms.Form
                            $formDE.Text = 'Modificación de la base de datos SQL SERVER'
                            $formDE.Size = New-Object System.Drawing.Size(500,300)
                            $formDE.StartPosition = 'CenterScreen'

                            $formDE.AcceptButton = $okButton
                            $formDE.Controls.add($okButton)

                            $formDE.CancelButton = $cancelButton
                            $formDE.Controls.add($cancelButton)

                            $labEliUser = New-Object System.Windows.Forms.Label
                            $labEliUser.Location = New-Object System.Drawing.Point(10,20)
                            $labEliUser.Size = New-Object System.Drawing.Size(150,20)
                            $labEliUser.Text = 'Ingrese la ruta del directorio: '
                            $formDE.Controls.add($labEliDir)

                            $txtEliUser = New-Object System.Windows.Forms.TextBox
                            $txtEliUser.Location = New-Object System.Drawing.Point(160,20)
                            $txtEliUser.Size = New-Object System.Drawing.Size(100,20)
                            $formDE.Controls.add($txtEliDir)


                            $formDE.TopMost = $true
                            $resultDE = $formDE.ShowDialog()

                            $eliDir = $txtEliDir.Text
                            

                            Invoke-Sqlcmd -Query "USE proyecto_programacion; DELETE FROM Directorios WHERE Nombre = '$eliDir';"
                            Invoke-Sqlcmd -Query "USE proyecto_programacion; SELECT * FROM Directorios;"
                        }
                    } 
                }
            }
        }

        "Usuarios locales" {
            $formUL = New-Object System.Windows.Forms.Form
            $formUL.Text = 'Inicio de programa'
            $formUL.Size = New-Object System.Drawing.Size(500,300)
            $formUL.StartPosition = 'CenterScreen'


            $formUL.AcceptButton = $okButton
            $formUL.Controls.add($okButton)

            $formUL.CancelButton = $cancelButton
            $formUL.Controls.add($cancelButton)

            $labOpcionUL = New-Object System.Windows.Forms.Label
            $labOpcionUL.Location = New-Object System.Drawing.Point(10,50)
            $labOpcionUL.Size = New-Object System.Drawing.Size(150,20)
            $labOpcionUL.Text = 'Elije una opción:'
            $formUL.Controls.add($labOpcionUL)


            $cbOpcionUL = New-Object System.Windows.Forms.ComboBox
            $cbOpcionUL.Location = New-Object System.Drawing.Point(160,50)
            $cbOpcionUL.Size = New-Object System.Drawing.Size(310,20)
            $cbOpcionUL.Items.AddRange(("Crear usuario", "Modificar Usuario", "Eliminar usuario"));
            $cbOpcionUL.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
            $formUL.Controls.add($cbOpcionUL)

            $formUL.TopMost = $true
            $resultUL = $formUL.ShowDialog()

            $opcionUL=$cbOpcionUL.SelectedItem

            switch($opcionUL){
                "Crear usuario"{
                    $formCU = New-Object System.Windows.Forms.Form
                    $formCU.Text = 'Creación de usuario'
                    $formCU.Size = New-Object System.Drawing.Size(500,300)
                    $formCU.StartPosition = 'CenterScreen'

                    $formCU.AcceptButton = $okButton
                    $formCU.Controls.add($okButton)

                    $formCU.CancelButton = $cancelButton
                    $formCU.Controls.add($cancelButton)

                    $labSQLUser = New-Object System.Windows.Forms.Label
                    $labSQLUser.Location = New-Object System.Drawing.Point(10,20)
                    $labSQLUser.Size = New-Object System.Drawing.Size(150,20)
                    $labSQLUser.Text = 'Ingrese usuario: '
                    $formCU.Controls.add($labSQLUser)

                    $txtSQLUser = New-Object System.Windows.Forms.TextBox
                    $txtSQLUser.Location = New-Object System.Drawing.Point(160,20)
                    $txtSQLUser.Size = New-Object System.Drawing.Size(100,20)
                    $formCU.Controls.add($txtSQLUser)

                    $labPuKey = New-Object System.Windows.Forms.Label
                    $labPuKey.Location = New-Object System.Drawing.Point(10,50)
                    $labPuKey.Size = New-Object System.Drawing.Size(150,20)
                    $labPuKey.Text = 'Ingrese llave publica: '
                    $formCU.Controls.add($labPuKey)

                    $txtPuKey = New-Object System.Windows.Forms.TextBox
                    $txtPuKey.Location = New-Object System.Drawing.Point(160,50)
                    $txtPuKey.Size = New-Object System.Drawing.Size(100,20)
                    $formCU.Controls.add($txtPuKey)

                    $labPrKey = New-Object System.Windows.Forms.Label
                    $labPrKey.Location = New-Object System.Drawing.Point(10,80)
                    $labPrKey.Size = New-Object System.Drawing.Size(150,20)
                    $labPrKey.Text = 'Ingrese llave privada: '
                    $formCU.Controls.add($labPrKey)

                    $txtPrKey = New-Object System.Windows.Forms.TextBox
                    $txtPrKey.Location = New-Object System.Drawing.Point(160,80)
                    $txtPrKey.Size = New-Object System.Drawing.Size(100,20)
                    $formCU.Controls.add($txtPrKey)

                    $labPassL = New-Object System.Windows.Forms.Label
                    $labPassL.Location = New-Object System.Drawing.Point(10,80)
                    $labPassL.Size = New-Object System.Drawing.Size(150,20)
                    $labPassL.Text = 'Ingrese contraseña: '
                    $formCU.Controls.add($labPassL)

                    $txtPassL = New-Object System.Windows.Forms.MaskedTextBox
                    $txtPassL.PasswordChar = '*'
                    $txtPassL.Location = New-Object System.Drawing.Point(160,50)
                    $txtPassL.Size = New-Object System.Drawing.Size(310,20)
                    $form.Controls.Add($txtPassL)

                    $formCU.TopMost = $true
                    $resultCU = $formCU.ShowDialog()

                    #Conversión de txtpassword a string seguro
                    $passwordSecure = ($txtPassword.Text | ConvertTo-SecureString -AsPlainText -Force -ErrorAction SilentlyContinue)


                    $LinxUser = $txtSQLUser.Text
                    $LinuxPuKey = $txtPuKey.Text
                    $LinuxPrKey = $txtPrKey.Text
                    $LinuxPass = $txtPassL.Text

                    if($resultado -eq [System.Windows.Forms.DialogResult]::OK){
                        $hayErrores = $false
                        $errores = ""
                        if ($login.Length -eq 0){
                            Write-Host "Favor de ingresar un nombre de usuario login"
                            $hayErrores = $true
                        }
                        if ($passwordSecure -eq 0){
                            Write-Host "Favor de ingresar contraseña"
                            $hayErrores = $true
                        }
                        if($fullName.Length -eq 0){
                            Write-Host "Favor de ingresar nombre completo"
                            $hayErrores = $true
                        }
                    #Si no hay errores se crea el usuario
                        if(!$hayErrores){
                            Set-Content -Value "1" -Path \\192.168.163.131\samba\tasks\bandera.txt -Force
                            Set-Content -Value "cd /home/benjamin/carpetaCompartida/scripts/ ; ./agregarUser.sh $LinxUser $LinuxPuKey $LinuxPrKey $LinuxPass #" -Path \\192.168.163.131\samba\tasks\comandos.sh
                        }

                    }
                    else{
                        Write-Host "Saliendo del programa..."
                    }


                }

                "Modificar Usuario"{

                }

                "Eliminar Usuario"{

                }
            }
        }

        default{}
    }

}
else{
    Write-Host "Adios!"
}
