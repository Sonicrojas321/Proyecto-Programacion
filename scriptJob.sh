#!/bin/bash

perl -p -i -e "s/\r//g" /home/benjamin/carpetaCompartida/tasks/bandera.txt
existe="/home/benjamin/carpetaCompartida/tasks/existe.txt"
bandera=$(cat /home/benjamin/carpetaCompartida/tasks/bandera.txt)

cd /home/benjamin/carpetaCompartida/tasks

while(test -e $existe)
do
	perl -p -i -e "s/\r//g" /home/benjamin/carpetaCompartida/tasks/bandera.txt
	bandera=$(cat /home/benjamin/carpetaCompartida/tasks/bandera.txt)

	sleep 1
	if [  $bandera == "1" ]
	then

	./comandos.sh

	echo "0" > /home/benjamin/carpetaCompartida/tasks/bandera.txt
	fi
done

echo "Se murio 'existe'"
