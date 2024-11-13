#!/bin/bash

# Asignar la ruta del archivo desde el primer parámetro
FILE_PATH="./scripts/in_order.py"

# Definir un arreglo de configuraciones (assoc, size)
declare -a configurations=(
    "1 8kB"
    "2 8kB"
    "4 8kB"
    "8 8kB"
    "1 16kB"
    "2 16kB"
    "4 16kB"
    "8 16kB"
    "1 32kB"
    "2 32kB"
    "4 32kB"
    "8 32kB"
)

# Iterar sobre cada configuración en el arreglo
for config in "${configurations[@]}"; do
    # Obtener el tamaño de vías (assoc) y el tamaño de memoria (size) de la configuración
    assoc_size=$(echo "$config" | cut -d ' ' -f 1)
    mem_size=$(echo "$config" | cut -d ' ' -f 2)

    # Actualizar el archivo con los nuevos valores
    sed -i '/class DCache(Cache):/,/class/{s/^\(\s*assoc\s*=\s*\).*$/\1'"$assoc_size"'/}' "$FILE_PATH"

    sed -i '/class DCache(Cache):/,/class/{s/^\(\s*size\s*=\s*\).*$/\1'"\"$mem_size\""'/}' "$FILE_PATH"

    # Ejecutar la simulación con la nueva configuración
    printf "cache %s\nvias %s\n\n" "$mem_size" "$assoc_size" >stats/stats-ej1-d/stats-$mem_size-$assoc_size.txt
    ./run_simulation.sh >>stats/stats-ej1-d/stats-$mem_size-$assoc_size.txt

    echo "Simulación ejecutada con 'vias'=$assoc_size y 'tamaño dcache'=$mem_size"
done
