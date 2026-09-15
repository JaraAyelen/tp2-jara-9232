#!/bin/bash

# Para evitar el uso de variables vacías y fallos silenciosos en tuberías
set -uo pipefail

# Definición de variables globales de filtrado
INICIALES="aj"
TERMINO_EXCLUIR="excluir"

# Definición de la función principal
procesar_pdfs() {
    local cantidad_pdfs
    cantidad_pdfs=$(find . -type f -name "*.pdf" | wc -l || true)

    if [[ "$cantidad_pdfs" -eq 0 ]]; then
        echo "No se encontraron archivos PDF para analizar."
        return 0
    fi

    # Procesar cada PDF encontrado línea por línea
    find . -type f -name "*.pdf" | while read -r archivo; do

        # Comprobar que sea un archivo regular y tenga permisos de lectura
        if [[ ! -f "$archivo" || ! -r "$archivo" ]]; then
            continue
        fi

	# Extraer solo el nombre del archivo
        local nombre_base
        nombre_base=$(basename "$archivo")

        # Omitir el archivo si su nombre coincide con los patrones de exclusión
        if [[ "$nombre_base" =~ $TERMINO_EXCLUIR || "$nombre_base" =~ $INICIALES ]]; then
            continue
        fi

	# Extraer la primera línea del archivo PDF
        local primera_linea
        primera_linea=$(head -n 1 "$archivo" 2>/dev/null || true)

        # Verificar si la línea capturada contiene el formato estándar de versión PDF
        if [[ "$primera_linea" =~ %PDF-([0-9]+\.[0-9]+) ]]; then
            local version="${BASH_REMATCH[1]}"
            echo "Archivo: [$nombre_base] - Versión PDF: [$version]"
        else
            echo "Archivo: [$nombre_base] - Versión PDF: [Formato no reconocido]"
        fi
    done
}

# Invocar la función para que el script se ejecute
procesar_pdfs
