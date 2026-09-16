#!/bin/bash

# Imprimir el mensaje de bienvenida
echo "Bienvenido/a al panel interactivo para monitoreo de recursos del sistema. Usted podrá:"

# Definir el mensaje del prompt
PS3="Ingrese el número de la opción deseada: "

# Definir las opciones disponibles para el menú interactivo
opciones=("Monitorear memoria RAM" "Buscar archivos grandes" "Espacio en particiones" "Salir")

# Iniciar un bucle infinito utilizando select para generar el menú numerado
select opcion in "${opciones[@]}"; do

    # Evaluar la opción seleccionada por el usuario (almacenada en la variable por defecto REPLY)
    case $REPLY in
        1)
            echo "Iniciando monitoreo de RAM. (Presione Ctrl+C para volver al menú)"
            # Pausa de 3 segundos para que se pueda leer el mensaje
            sleep 3
	    # Ejecutar el comando free -m de forma continua cada 2 segundos
            watch -n 2 free -m
            ;;
        2)
            echo ""
	    echo "Buscando los 5 archivos más grandes (mayores a 10MB) en $HOME . . ."
            echo ""
	    # Buscar archivos mayores a 10MB, calcular su tamaño, enviar los errores a /dev/null
	    # Ordenar los archivos de mayor a menor y mostrar los primeros 5
            find "$HOME" -type f -size +10M -exec du -h {} + 2>/dev/null | sort -rh | head -n 5
            ;;
        3)
	    echo ""
            echo "Espacio en discos de particiones físicas:"
            echo ""
	    # Mostrar el uso de espacio en disco y filtrar las particiones físicas que comienzan con /dev/
            df -h | grep '^/dev/'
            ;;
        4)
 	    echo ""
            echo "Sesión de monitoreo finalizada. Alumna Jara Ayelen (Legajo 9232)"
            # Interrumpir el bucle select para finalizar la ejecución del script
            break
            ;;
        *)
            # Capturar cualquier ingreso no válido y solicitar nuevamente una opción correcta
            echo ""
	    echo "Opción inválida. Por favor, ingrese un número del 1 al 4."
            ;;
    esac

    # Imprimir una línea en blanco para separar visualmente las iteraciones del menú
    echo ""
done
