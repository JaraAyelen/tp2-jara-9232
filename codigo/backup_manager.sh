#!/bin/bash

# Para evitar el uso de variables vacías y fallos silenciosos en tuberías
set -uo pipefail

# Definir variables de configuración
LEGAJO="9232"
LOCK_DIR="/var/lock/backup_${LEGAJO}.lock"
DIR_TEMP="/tmp/backup_${LEGAJO}"
DIR_CODIGO="codigo" 
FECHA=$(date '+%Y%m%d_%H%M%S')
ARCHIVO_BACKUP="logs/backup_${LEGAJO}_${FECHA}.tar.gz"

# MECANISMO DE LOCKFILE
# Intentar crear el directorio de bloqueo. Si falla, el script se interrumpe.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Error: El script ya se está ejecutando (lockfile existente en $LOCK_DIR)."
    exit 9
fi

# Eliminae el directorio de bloqueo al finalizar
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

echo "Iniciando proceso de respaldo..."

# RESPALDO
# Preparar el directorio temporal (borrarlo si existe y crearlo de nuevo)
rm -rf "$DIR_TEMP"
mkdir -p "$DIR_TEMP"

echo "Copiando archivos modificados en las últimas 24 horas..."
# Buscar archivos en la carpeta de código modificados hace menos de 1 día (-mtime -1)
# y copiarlos al directorio temporal usando -exec
find "$DIR_CODIGO" -type f -mtime -1 -exec cp {} "$DIR_TEMP/" \;

echo "Empaquetando el respaldo..."
# Empaquetar y comprimir el directorio temporal, ubicándose en /tmp antes
tar -czf "$ARCHIVO_BACKUP" -C "/tmp" "backup_${LEGAJO}"

# Limpiar el directorio temporal de trabajo
rm -rf "$DIR_TEMP"

echo "Respaldo finalizado con éxito en: $ARCHIVO_BACKUP"
