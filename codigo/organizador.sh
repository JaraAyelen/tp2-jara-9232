#!/bin/bash

# Para evitar el uso de variables vacías y fallos silenciosos en tuberías
set -uo pipefail

# Verificar que se haya recibido un  parámetro (la ruta de un directorio)
if [[ $# -ne 1 ]]; then
    echo "Error: Faltan argumentos."
    echo "Uso correcto: $0 <directorio_destino>"
    exit 1
fi

# Capturar el primer argumento ingresado por el usuario
DESTINO="$1"

# Comprobar la existencia y accesibilidad del directorio
if [[ ! -d "$DESTINO" || ! -w "$DESTINO" ]]; then
    echo "Error: El directorio destino no existe o no es accesible para escritura."
    exit 1
fi

# Crear las carpetas para la clasificación
mkdir -p "$DESTINO/imagenes" "$DESTINO/documentos" "$DESTINO/comprimidos" "$DESTINO/otros"

# Recorrer y clasificar los archivos del directorio destino
for archivo in "$DESTINO"/*; do

    # Procesar solo los archivos regulares (ej: si es una carpeta lo ignora)
    if [[ ! -f "$archivo" ]]; then
        continue
    fi
    # Extraer solo el nombre del archivo
    nombre_base=$(basename "$archivo")

    # Renombrar los archivos .old
    # Usar comodines para identificar si el archivo termina en la extensión .old
    if [[ "$nombre_base" == *.old ]]; then
        # Utilizar la sustitución de cadenas de Bash para reemplazar la extensión .old por .backup
        nuevo_nombre="${nombre_base%.old}.backup"
        # Mover el archivo a la carpeta destino con el nuevo nombre
        mv "$archivo" "$DESTINO/$nuevo_nombre"

        # Actualizar las variables para luego poder clasificar el archivo renombrado
        archivo="$DESTINO/$nuevo_nombre"
        nombre_base="$nuevo_nombre"
    fi

    # Clasificar los archivos según la extensión
    # Usar la estructura 'case' para evaluar las extensiones
    # Mover los archivos al directorio correcto
    case "$nombre_base" in
        *.jpg|*.png|*.jpeg)
            mv "$archivo" "$DESTINO/imagenes/"
            ;;
        *.pdf|*.txt|*.docx|*.odt)
            mv "$archivo" "$DESTINO/documentos/"
            ;;
        *.zip|*.tar.gz|*.rar)
            mv "$archivo" "$DESTINO/comprimidos/"
            ;;
        *)
            mv "$archivo" "$DESTINO/otros/"
            ;;
    esac
done

# Informar la finalización exitosa del script
echo "Organización de archivos en el directorio: $DESTINO completa."
