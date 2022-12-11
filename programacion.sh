#!/bin/bash

#Código que realizará las acciones necesarios acorde al proyecto de programación

#Creación de Menú para realizar las distintas acciones
optionMainMenu=$(dialog --title "Menu principal:" \
		--stdout \
		--menu "¿Qué acción desea realizar?" 0 0 3 \
				1 "Iniciar el programa" \
				2 "Edición de usuarios" \
				3 "Edición de directorios" \
				4 "Salir")
echo "$optionMainMenu"

#Variables para el ingreso a mysql
userMysql="root"
password="Yuihirasawa1"

#Instancia Case acorde a lo seleccionado en el Menú anterior
case $optionMainMenu in
	#En caso de selecciona la opción 1. Iniciar programa se hace:
	1)
		#Menú donde se ingresará el nombre del usuario, se sacarán los usuarios de la base de datos y se guardaran en un variable (resultado esperado 1 usuario)
		userDialog=$(dialog --title "Iniciando el programa" \
                		    --stdout \
		                   --inputbox "Ingresa el nombre del usuario" 0 0)
		sql="SELECT usuario FROM usuarios WHERE usuario = '$userDialog'"
		i=0
		while IFS=$'\t' read usuariosql
		do
			USUARIOSQL[$i]=$usuariosql
			((i++))
		done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;")

		echo "El usuario ingresado es: $userDialog"
		echo
		echo "El usuario de la base de datos es: ${USUARIOSQL[1]}"

		#Se guardará el usuario dentro de la variable userConfirm, la razón por la cual es [1] es porque [0] es el nombre de columna
		userConfirm=${USUARIOSQL[1]}

		#Si el usuario ingresado coincide con el que está en la Base de Datos mostrará el siguiente Menú
		if [ $userDialog == $userConfirm ]
		then
		        echo "Usuario existe y es: $userDialog"
			optionMenu1=$(dialog --title "Inicio del programa" \
					--stdout \
					--menu "Selecciona una opción:" 0 0 3 \
						1 "Subir archivos" \
						2 "Crear directorios"  \
                                                3 "Listar procesos"  \
                                                4 "Detener procesos"  \
						5 "Listar archivos y Directorios" \
                                                6 "Enviar archivos..."  \
                                                7 "Enviar mensaje"  \
                                                8 "Revisar mensajes"  \
                                                9 "Salir" )
			echo "La opción elegida fueeee: $optionMenu1"

			#Otro case para este Menú
			case $optionMenu1 in
#En caso de seleccionar la opción 1. Subir Archivos
				1)
					#Mostrará ventana donde te dejará seleccionar archivos de Linux y poder subirlos a Windows
					echo "Subir archivos"
					optionMenu1Sub1=$(dialog --title "Selecciona el archivo que desees subir" \
								--stdout \
								--fselect "/home/benjamin/" 14 70 )

					#En caso de que el archivo exista mostrará un Menú yesno para confirmar la subida
					if [ -f "$optionMenu1Sub1" ]
					then
						dialog --title "Se subirá el archivo ${optionMenu1Sub1}" \
							--yesno "¿Estás seguro?" 0 0

						#Guardar solamente la última parte de la liga completa de la ubicación de un archivo
						archivoSinliga=$(echo "$optionMenu1Sub1" | rev | cut -d'/' -f 1 | rev)

						#Se copia el archivo a la carpeta compartida
						cp $optionMenu1Sub1 /home/benjamin/carpetaCompartida/tmp/$archivoSinliga

						#Se saca la id del usuario para poder saber los directorios:
						idUser="SELECT id_user FROM usuarios WHERE usuario = '$userConfirm'"

						j=0
						while IFS=$'\t' read ids
						do
							IDUSUARIO[$j]=$ids
							((j++))

						done < <(mysql -u $userMysql -p$password proyecto_programacion -e "$idUser;")

						echo "La id del usuario es: ${IDUSUARIO[1]}"

						#Se sacan los directorios que se encuentran en la base de datos:
						sql="SELECT directorio FROM directorios INNER JOIN usuarios ON usuarios.id_user = directorios.id_user WHERE directorios.id_user = ${IDUSUARIO[1]}"
				                i=0
				                while IFS=$'\t' read directoriosSql
				                do
				                        DIRECTORIOSQL[$i]="$i $directoriosSql"
				                        ((i++))
				                done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;" | tail -n +2)


						#Mostrará un menú con los directorios a donde se podrá subir el archivo
						directorioSeleccionado=$(dialog --title "Seleccionar directorio" \
										--stdout \
										--menu "Selecciona el directorio:" 0 0 0 \
											${DIRECTORIOSQL[@]})

						#Quitar número de DIRECTORIOSQL
                                                directorioDestino=$(echo "${DIRECTORIOSQL[$directorioSeleccionado]}" | cut -d ' ' -f2)

						directorioWindows=$(echo $directorioDestino |  tr '/' '\\')
						#Aqui va lo que irá dentro del archivo que leerá powershell
						sharedFolder=$(echo "//192.168.163.131/SAMBA/tmp/$archivoSinliga" | tr '/' '\\')
						echo "Move-Item -Path $sharedFolder -Destination $directorioWindows -Force" > /home/benjamin/carpetaCompartida/tasks/comandos.ps1

						mv /home/benjamin/carpetaCompartida/tasks/band.txt /home/benjamin/carpetaCompartida/tasks/bandera.txt

					fi
					;;
#Inicio del punto 2
                                2)
                                        echo "Crear directorios"
					#Mostrará una ventana donde nos permitirá escribir el nombre del nuevo directorio
					folderDialog=$(dialog --title "Creando dirrectorios" \
                			                    --stdout \
		                        	           --inputbox "Ingresa el nombre del nuevo directorio que desees crear:" 0 0)

					#Se saca la id del usuario para poder saber los directorios:
					idUser="SELECT id_user FROM usuarios WHERE usuario = '$userConfirm'"
					j=0
					while IFS=$'\t' read ids
					do
						IDUSUARIO[$j]=$ids
						((j++))
					done < <(mysql -u $userMysql -p$password proyecto_programacion -e "$idUser;")

					echo "La id del usuario es: ${IDUSUARIO[1]}"

					#Se sacan los directorios que se encuentran en la base de datos:
					sql="SELECT directorio FROM directorios INNER JOIN usuarios ON usuarios.id_user = directorios.id_user WHERE directorios.id_user = ${IDUSUARIO[1]}"
			                i=0
			                while IFS=$'\t' read directoriosSql
			                do
			                        DIRECTORIOSQL[$i]="$i $directoriosSql"
			                        ((i++))
			                done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;" | tail -n +2)

					echo "${DIRECTORIOSQL[0]}"
					echo "${DIRECTORIOSQL[1]}"
					echo "${DIRECTORIOSQL[2]}"


					#Mostrará un menú con los directorios a donde se podrá crear el directorio
					directorioSeleccionado=$(dialog --title "Seleccionar directorio" \
									--stdout \
									--menu "Selecciona el directorio donde quieres insertar dicho directorio:" 0 0 0 \
										${DIRECTORIOSQL[@]})

					#Quitar número de DIRECTORIOSQL
                                        directorioDestino=$(echo "${DIRECTORIOSQL[$directorioSeleccionado]}" | cut -d ' ' -f2)

					#Código donde mandará el código para que powershell cree el directorio en el directtorio seleccionado
					echo "$folderDialog se creará en $directorioDestino"

					#Mandar señal para que el directorio se cree en el directorio destino
					rutaFinal=$(echo "$directorioDestino" | tr '/' '\\')
					echo "New-Item -Path $rutaFinal -Name $folderDialog -ItemType Directory -Force" > carpetaCompartida/tasks/comandos.ps1
					mv /home/benjamin/carpetaCompartida/tasks/band.txt /home/benjamin/carpetaCompartida/tasks/bandera.txt

                                        ;;
#Inicio de la opción 3
                                3)
                                        echo "Listar procesos"
					#Solicitar un archivo que posea los procesos que se estén ejecutando en Windows, dicho archivo estará ubicado en la carpeta compartida


					#Una vez creado el archivo en carpetaCompartida/tmp/procesos.txt
					i=0
					while IFS= read -r line
					do
						echo "$1 $line"
						PROCESOS[$i]="$i $line"
						((i++))
					done < /home/benjamin/carpetaCompartida/tmp/procesos.txt

					#Ventana que permite observar los procesos en ejecución
					#salida=$(dialog --title "Procesos de Windows en Ejecución:" \
					#		--stdout \
					#		--menu "Procesos:" 0 0 0 \
					#			${PROCESOS[@]})


					#Quitar número de PROCESOS
                                        procesosBuenos=$(echo "${PROCESOS[$salida]}" | cut -d ' ' -f2)


					echo "El proceso seleccionado fue: $procesosBuenos"
                                        ;;
                                4)
#inicio de la opción 4
                                        echo "Detener procesos"

					#Solicitar un archivo que posea los procesos que se estén ejecutando en Windows, dicho archivo estará ubicado en la carpeta compartida
					echo "(Get-Process | Select-Object -Property ProcessName) | Export-CSV -Path //192.168.163.131/samba/tmp/buffer.csv -Force" | tr '/' '\\' > carpetaCompartida/tasks/comandos.ps1
					mv /home/benjamin/carpetaCompartida/tasks/band.txt /home/benjamin/carpetaCompartida/tasks/bandera.txt

					sleep 5

                                        #Una vez creado el archivo en carpetaCompartida/tmp/buffer.
                                        i=0
                                        while IFS="," read -r line
                                        do
						echo "$i $line"
                                                PROCESOS[$i]="$i $line"
                                                ((i++))
                                        done < <(tail -n +3 /home/benjamin/carpetaCompartida/tmp/buffer.csv | perl -p -i -e "s/\r//g")

                                        #Ventana que permite observar los procesos en ejecución
                                        salida=$(dialog --title "Procesos de Windows en Ejecución:" \
                                                        --stdout \
                                                        --menu "Proceso a matar:" 0 0 0 \
                                                                ${PROCESOS[@]})


                                        #Quitar número de PROCESOS
                                        procesoBueno=$(echo "${PROCESOS[$salida]}" | cut -d ' ' -f 2)


                                        echo "El proceso seleccionado fue: $procesoBueno"
					#mandar a matar a $procesoBueno
					#echo "Stop-Process -Name $procesoBueno" > /home/benjamin/carpetaCompartida/tasks/comandos.ps1
                                        #echo "1" > /home/benjamin/carpetaCompartida/tasks/bandera.txt


                                        ;;
                                5)
#Inicio de la opción 5, Listar archivos
                                        #Se saca la id del usuario para poder saber los directorios:
                                        idUser="SELECT id_user FROM usuarios WHERE usuario = '$userConfirm'"
                                        j=0
                                        while IFS=$'\t' read ids
                                        do
                                                IDUSUARIO[$j]=$ids
                                                ((j++))
                                        done < <(mysql -u $userMysql -p$password proyecto_programacion -e "$idUser;")

                                        echo "La id del usuario es: ${IDUSUARIO[1]}"


					echo "Listar Archivos"

					#Seleccionamiento de directorios de $userConfirm
					sql="SELECT directorio FROM directorios INNER JOIN usuarios ON usuarios.id_user = directorios.id_user WHERE directorios.id_user = ${IDUSUARIO[1]}"
                                        i=0
                                        while IFS=$'\t' read directoriosSql
                                        do
                                                DIRECTORIOSQL[$i]="$i $directoriosSql"
                                                ((i++))
                                        done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;" | tail -n +2)



                                        #Mostrará un menú con los directorios a los cuales se podrán listar sus archivos
                                       directorioListar=$(dialog --title "Seleccionar directorio" \
                                                                        --stdout \
                                                                        --menu "Selecciona el directorio donde quieres insertar dicho directorio:" 0 0 0 \
                                                                                ${DIRECTORIOSQL[@]})

                                        #Quitar número de DIRECTORIOSQL
                                        directorioDestino=$(echo "${DIRECTORIOSQL[$directorioListar]}" | cut -d ' ' -f2)

					#Mandar señal a Windows para que saque los archivos de directorioDestino
					rutaFinal=$(echo "$directorioDestino" | tr '/' '\\')

					(echo "(Get-Childitem $rutaFinal | Select-Object -Property Mode, Length, Name) | Export-CSV -Path //192.168.163.131/samba/tmp/buffer.csv -force") | tr '/' '\\' > carpetaCompartida/tasks/comandos.ps1
					mv /home/benjamin/carpetaCompartida/tasks/band.txt /home/benjamin/carpetaCompartida/tasks/bandera.txt

					echo "Los archivos de $rutaFinal son:"

					while IFS="," read -r mode length name
					do
						echo "$mode $length $name"
					done < <(tail -n +3 carpetaCompartida/tmp/buffer.csv)
                                        ;;
                                6)
#Inicio de la opción 6
                                        echo "Enviar archivos"
                                        #Mostrará ventana donde te dejará seleccionar archivos de Linux y poder subirlos a Windows
                                        echo "Subir archivos"
                                        optionMenu1Sub1=$(dialog --title "Selecciona el archivo que desees subir" \
                                                                --stdout \
                                                                --fselect "/home/benjamin/" 14 70 )

                                        #En caso de que el archivo exista mostrará un Menú yesno para confirmar la subida
                                        if [ -f "$optionMenu1Sub1" ]
                                        then
                                                dialog --title "Se subirá el archivo ${optionMenu1Sub1}" \
                                                        --yesno "¿Estás seguro?" 0 0

                                                #Guardar solamente la última parte de la liga completa de la ubicación de un archivo
                                                archivoSinliga=$(echo "$optionMenu1Sub1" | rev | cut -d'/' -f 1 | rev)

                                                #Se copia el archivo a la carpeta compartida
                                                cp $optionMenu1Sub1 /home/benjamin/carpetaCompartida/$archivoSinliga

                                                #Se saca la id del usuario para poder saber los directorios:
                                                idUser="SELECT id_user FROM usuarios WHERE usuario = '$userConfirm'"

                                                j=0
                                                while IFS=$'\t' read ids
                                                do
                                                        IDUSUARIO[$j]=$ids
                                                        ((j++))

                                                done < <(mysql -u $userMysql -p$password proyecto_programacion -e "$idUser;")

						echo "La id del usuario es: ${IDUSUARIO[1]}"

                                                #Se sacan los directorios que se encuentran en la base de datos:
                                                sql="SELECT directorio FROM directorios INNER JOIN usuarios ON usuarios.id_user = directorios.id_user WHERE directorios.id_user = ${IDUSUARIO[1]}"
                                                i=0
                                                while IFS=$'\t' read directoriosSql
                                                do
                                                        DIRECTORIOSQL[$i]="$i $directoriosSql"
                                                        ((i++))
                                                done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;" | tail -n +2)


                                                #Mostrará un menú con los directorios a donde se podrá subir el archivo
                                                directorioSeleccionado=$(dialog --title "Seleccionar directorio" \
                                                                                --stdout \
                                                                                --menu "Selecciona el directorio:" 0 0 0 \
                                                                                        ${DIRECTORIOSQL[@]})

                                                #Quitar número de DIRECTORIOSQL
                                                directorioDestino=$(echo "${DIRECTORIOSQL[$directorioSeleccionado]}" | cut -d ' ' -f2)

                                                #Aqui va lo que irá dentro del archivo que leerá powershell
                                                echo "Los archivos se enviarán a: $directorioDestino"

                                        fi


                      	                ;;
                                7)
#Inicio de la opción 7
                                        echo "Enviar mensaje"
                                        mensaje=$(dialog --title "Enviar Mensajes" \
                                                        --stdout \
                                                        --inputbox "Escriba su mensaje" 0 0)
                                        echo "$mensaje \t" >> /home/benjamin/carpetaCompartida/msg/mensajes.txt


                                        ;;
                                8)
                                        echo "Revisar mensajes"
					opcionMsg=$(dialog --title "Recibir mensajes:" \
						--yesno)
                                        ;;
				*)
					echo "..."
					;;
			esac

		else
		        echo "Usuario no existe en la base de datos"
		fi

		;;

	2)
		#Menú para lo que desee hacer con los usuarios: (Modificar base de datos y en equipo)
                echo "Editando usuarios..."
		optionMenu2=$(dialog --title "Modificación de usuarios:" \
					--stdout \
					--menu "Seleccionar una acción" 0 0 0 \
						1 "Dar de alta un usuario" \
						2 "Modificar usuario" \
						3 "Eliminar un usuario" \
						4 "Salir" )

		case $optionMenu2 in
			1)
				#Dar de alta a un usuario en MySQL
				datosAltaMysql=$(dialog --title "Alta de usuarios de MySQL" \
					--separate-widget $"\n" \
					--form "Introduce los datos del usuarios" \
					0 0 0 \
					"Nombre:" 1 1 "$nombre" 1 10 20 0 \
					"Llave publica:" 2 1 "$llavePub" 2 10 20 0 \
					"Llave privada:" 3 1 "$llavePri" 3 10 20 0 \
					3>&1 1>&2 2>&3 3>&-)

				#Consulta
				nombre=$(echo "$datosAltaMysql" | sed -n 1p)
				llavePub=$(echo "$datosAltaMysql" | sed -n 2p)
				llavePri=$(echo "$datosAltaMysql" | sed -n 3p)
				insertarSQL="INSERT INTO usuarios (usuario, llave_publica, llave_privada) VALUES ('$nombre', '$llavePub', '$llavePri')"

				mysql -u $userMysql -p$password proyecto_programacion -e "$insertarSQL;"

				;;
			2)
				#Modificar un usuario en MySQL
				#Pedir un usuario
				userDialog=$(dialog --title "Iniciando el programa" \
                		    --stdout \
		                   --inputbox "Ingresa el nombre del usuario" 0 0)

				sql="SELECT usuario FROM usuarios WHERE usuario = '$userDialog'"
				i=0
				while IFS=$'\t' read usuariosql2
				do
					USUARIOSQL[$i]=$usuariosql2
					((i++))
				done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;")

				echo "El usuario ingresado es: $userDialog"
				echo ""
				echo "El usuario de la base de datos es: ${USUARIOSQL[1]}"

				#Se guardará el usuario dentro de la variable userConfirm, la razón por la cual es [1] es porque [0] es el nombre de columna
				userConfirm=${USUARIOSQL[1]}

				echo "$userConfirm"
				if [ "$userConfirm" == "$userDialog" ]
				then
					datosModMysql=$(dialog --title "Modificacion de usuarios de MySQL" \
                	                       			--separate-widget $"\n" \
                        	                		--form "Introduce los datos del usuarios" \
                                	        		0 0 0 \
                                	        		"Nombre:" 1 1 "$nombre" 1 10 20 0 \
                                	        		"Llave publica:" 2 1 "$llavePub" 2 10 20 0 \
                              					"Llave privada:" 3 1 "$llavePri" 3 10 20 0 \
	                                       			3>&1 1>&2 2>&3 3>&- )

        	                        #Consulta
	                                nombre=$(echo "$datosModMysql" | sed -n 1p)
	                                llavePub=$(echo "$datosModMysql" | sed -n 2p)
	                                llavePri=$(echo "$datosModMysql" | sed -n 3p)
	                                actualizarSQL="UPDATE usuarios SET usuario='$nombre', llave_publica='$llavePub', llave_privada='$llavePri' WHERE usuario = '$userDialog'"

	                                mysql -u $userMysql -p$password proyecto_programacion -e "$actualizarSQL;"

				fi

				;;
			3)
				#Eliminar un Usuario de MySQL
				#Eliminar un directorio en MYSQL
                                #Mostrará una ventana donde nos permitirá escribir el nombre del nuevo directorio
                                userConfirm=$(dialog --title "Eliminación de directorio" \
                                                    --stdout \
                                                   --inputbox "Ingresa el nombre del usuario:" 0 0)

                                #Se saca la id del usuario para poder saber los directorios:
                                idUser="SELECT id_user FROM usuarios WHERE usuario = '$userConfirm'"
                                j=0
                                while IFS=$'\t' read ids
                                do
                                        IDUSUARIO[$j]=$ids
                                        ((j++))
                                done < <(mysql -u $userMysql -p$password proyecto_programacion -e "$idUser;")

                                echo "La id del usuario es: ${IDUSUARIO[1]}"
				userDelete="${IDUSUARIO[1]}"



				dialog --title "Eliminacion de Usuario" \
                                        --yesno "¿Estás seguro?" 0 0
                                ans=$?
                                if [ $ans -eq 0 ]
                                then
                                        mysql -u $userMysql -p$password  proyecto_programacion -e "DELETE FROM usuarios WHERE id_user='$userDelete';"
				else
					echo "Ta bien"
				fi
                                ;;

			*)
				echo "Saliendo..."
				;;
		esac
                ;;

	3)
                echo "Editando directorios..."
		optionMenu3=$(dialog --title "Modificación de directorios:" \
                                        --stdout \
                                        --menu "Seleccionar una acción" 0 0 0 \
                                                1 "Dar de alta un directorio" \
                                                2 "Modificar directorio" \
                                                3 "Eliminar un directorio" \
                                                4 "Salir" )
		case $optionMenu3 in
                        1)
                                #Dar de alta un directorio en MySQL
				datosAltaDirMysql=$(dialog --title "Alta de usuarios de MySQL" \
                                        --separate-widget $"\n" \
                                        --form "Introduce los datos del usuarios" \
                                        0 0 0 \
                                        "Directorio:" 1 1 "$directorio" 1 10 20 0 \
                                        "ID_User:" 2 1 "$iduser" 2 10 20 0 \
                                        3>&1 1>&2 2>&3 3>&-)

                                #Consulta
                                directorio=$(echo "$datosAltaDirMysql" | sed -n 1p)
                                iduser=$(echo "$datosAltaDirMysql" | sed -n 2p)

                                insertarDSQL="INSERT INTO directorios (directorio, id_user) VALUES ('$directorio', '$iduser')"

				mysql -u $userMysql -p$password proyecto_programacion -e "$insertarDSQL;"
                                ;;
                        2)
                               #Modificar directorio
                                userDialog=$(dialog --title "Iniciando el programa" \
                                    --stdout \
                                   --inputbox "Ingresa el nombre del usuario" 0 0)

                                sql="SELECT usuario FROM usuarios WHERE usuario = '$userDialog'"
                                i=0
                                while IFS=$'\t' read usuariosql
                                do
                                        USUARIOSQL[$i]=$usuariosql
                                        ((i++))
                                done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;")

                                echo "El usuario ingresado es: $userDialog"
                                echo ""
                                echo "El usuario de la base de datos es: ${USUARIOSQL[1]}"

                                #Se guardará el usuario dentro de la variable userConfirm, la razón por la cual es [1] es porque [0] es el nombre de columna
                                idConfirm="${USUARIOSQL[1]}"

				userConfirm=$(mysql -u $userMysql -p$password proyecto_programacion -e "Select id_user FROM directorios WHERE id_user = '$idConfirm';" | tail -n +2)

                                if [ "$userConfirm" == "$userDialog" ]
				then

                                       directorioListar=$(dialog --title "Seleccionar directorio" \
                                                                        --stdout \
                                                                        --menu "Selecciona el directorio donde quieres insertar dicho directorio:" 0 0 0 \
                                                                                ${DIRECTORIOSQL[@]})

                                       #Quitar número de DIRECTORIOSQL
                                       directorioFinal=$(echo "${DIRECTORIOSQL[$directorioListar]}" | cut -d ' ' -f2)



					datosModMysqlD=$(dialog --title "Modificacion de directorios de MySQL" \
                                                --separate-widget $"\n" \
                                                --form "Introduce los datos del directorio" \
                                                0 0 0 \
                                                "Directorio:" 1 1 "$nombre" 1 10 20 0 \
                                                3>&1 1>&2 2>&3 3>&-)

                                        #Consulta
                                        direc=$(echo "$datosModMysqlD" | sed -n 1p)

                                       actualizarDSQL="UPDATE directorios SET directorio='$direc', id_user='$idser' WHERE directorio='$disrectorioFinal';"

                                       mysql -u $userMysql -p$password proyecto_programacion -e "$actualizarDSQL"

                                fi

                                ;;
                        3)
                                #Eliminar un directorio en MYSQL
				#Mostrará una ventana donde nos permitirá escribir el nombre del nuevo directorio
				userConfirm=$(dialog --title "Eliminación de directorio" \
               			                    --stdout \
	                        	           --inputbox "Ingresa el nombre del usuario:" 0 0)

				#Se saca la id del usuario para poder saber los directorios:
				idUser="SELECT id_user FROM usuarios WHERE usuario = '$userConfirm'"
				j=0
				while IFS=$'\t' read ids
				do
					IDUSUARIO[$j]=$ids
					((j++))
				done < <(mysql -u $userMysql -p$password proyecto_programacion -e "$idUser;")

				echo "La id del usuario es: ${IDUSUARIO[1]}"

				#Se sacan los directorios que se encuentran en la base de datos:
				sql="SELECT directorio FROM directorios INNER JOIN usuarios ON usuarios.id_user = directorios.id_user WHERE directorios.id_user = ${IDUSUARIO[1]}"
		                i=0
		                while IFS=$'\t' read directoriosSql
		                do
		                        DIRECTORIOSQL[$i]="$i $directoriosSql"
		                        ((i++))
		                done  < <(mysql -u $userMysql -p$password proyecto_programacion -e "$sql;" | tail -n +2)

				#echo "${DIRECTORIOSQL[0]}"
				#echo "${DIRECTORIOSQL[1]}"
				#echo "${DIRECTORIOSQL[2]}"


				#Mostrará un menú con los directorios de los cuales se podrán eliminar el directorio
				directorioSeleccionado=$(dialog --title "Seleccionar directorio" \
								--stdout \
								--menu "Selecciona el directorio donde quieres insertar dicho directorio:" 0 0 0 \
									${DIRECTORIOSQL[@]})

				#Quitar número de DIRECTORIOSQL
                                directorioDestino=$(echo "${DIRECTORIOSQL[$directorioSeleccionado]}" | cut -d ' ' -f2)

				dialog --title "Eliminacion de Directorio" \
					--yesno "¿Estás seguro?" 0 0
				ans=$?
				if [ $ans -eq 0 ]
				then
					mysql -u $userMysql -p$password  proyecto_programacion -e "DELETE FROM directorios WHERE directorio='$directorioDestino';"
				else
					echo "ta bien"
				fi
                                ;;
                        *)
				echo "Saliendo..."
                                ;;
		esac
                ;;

	*)
		echo "Saliendo..."
		dialog --title "Adios!" \
				--infobox "Hasta luego..." 0 0
		;;
esac
