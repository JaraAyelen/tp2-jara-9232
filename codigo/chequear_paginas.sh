#!/bin/bash

# Para evitar el uso de variables vacías y fallos silenciosos en tuberías
set -uo pipefail

# Definir variables de configuración
ARCHIVO_SITIOS="pruebas/sitios_9232.txt"
ARCHIVO_LOG="logs/chequeo_9232.log"

# Definir los códigos de escape ANSI para los colores de la terminal
COLOR_VERDE='\033[0;32m'
COLOR_AMARILLO='\033[1;33m'
COLOR_ROJO='\033[0;31m'
SIN_COLOR='\033[0m'

# Determinar si se ingresaron URLs por argumento o si se debe leer el archivo
if [[ $# -eq 0 ]]; then
    echo "No se ingresaron argumentos. Leyendo URLs desde $ARCHIVO_SITIOS..."

    # Verificar que el archivo de texto exista
    if [[ ! -f "$ARCHIVO_SITIOS" ]]; then
        echo "Error: El archivo $ARCHIVO_SITIOS no fue encontrado."
        exit 1
    fi

    # Cargar todas las líneas del archivo en el arreglo 'lista_urls'
    mapfile -t lista_urls < "$ARCHIVO_SITIOS"
else
    # Capturar todos los argumentos ingresados por el usuario en el arreglo
    lista_urls=("$@")
fi

echo "Iniciando escaneo HTTP..."
echo "---------------------------------"

# Iterar sobre la lista de URLs (ya sea del archivo o de los argumentos)
for url in "${lista_urls[@]}"; do

    # Omitir líneas vacías en caso de que el archivo tenga espacios en blanco al final
    if [[ -z "$url" ]]; then
        continue
    fi

    # Realizar petición HTTP silenciosa (--max-time 10 evita esperas muy largas)
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")

    # Preparar la base del mensaje para guardar en el log
    mensaje_log="$url - Código: $status_code"

    # Evaluar el código HTTP
    case $status_code in
        200)
            mensaje_consola="${COLOR_VERDE}$url - Código: $status_code (OK)${SIN_COLOR}"
            mensaje_log="$mensaje_log (OK)"
            ;;
        3*)
            mensaje_consola="${COLOR_AMARILLO}$url - Código: $status_code (Redirección)${SIN_COLOR}"
            mensaje_log="$mensaje_log (Redirección)"
            ;;
        4*|5*)
            mensaje_consola="${COLOR_ROJO}$url - Código: $status_code (Error)${SIN_COLOR}"
            mensaje_log="$mensaje_log (Error)"
            ;;
        000)
            #Si no hay conexión a internet o el dominio no existe
            mensaje_consola="${COLOR_ROJO}$url - Código: $status_code (Fallo de conexión/Timeout)${SIN_COLOR}"
            mensaje_log="$mensaje_log (Fallo de conexión/Timeout)"
            ;;
        *)
            mensaje_consola="$url - Código: $status_code (Desconocido)"
            mensaje_log="$mensaje_log (Desconocido)"
            ;;
    esac

    # Imprimir el mensaje con colores en la terminal
    echo -e "$mensaje_consola"

    # Adjuntar el mensaje al archivo de log
    echo "$mensaje_log" >> "$ARCHIVO_LOG"

done

echo "---------------------------------"
echo "Reporte guardado exitosamente en $ARCHIVO_LOG"
