# Glosario

- **system.cpu_cluster.cpus.numCycles**: Número total de ciclos de reloj que la CPU uso para procesar las instrucciones.

- **system.cpu_cluster.cpus.dcache.overallHits::total**: Número total de aciertos en la caché de datos (data cache).

- **system.cpu_cluster.cpus.dcache.ReadReq.hits::total**: Número total de aciertos en la caché de datos específicamente para solicitudes de lectura.

- **system.cpu_cluster.cpus.icache.overallHits::total**: Número total de aciertos en la caché de instrucciones (instruction cache).

- **system.cpu_cluster.cpus.idleCycles**: Número total de ciclos de reloj en los que la CPU estuvo inactiva (idle), es decir, no estaba realizando ningún trabajo útil.
  - Obs: Un número elevado de ciclos inactivos puede ser un indicativo de que la CPU no está siendo utilizada de manera eficiente, ya sea por un cuello de botella en otros componentes del sistema o por una baja carga de trabajo.

## Branch Predictor

- **Ramas**: Puntos de decisión dentro de un programa donde la ejecución puede seguir diferentes caminos según una condición o valor.

- **BTB (Branch Target Buffer)**: Es una estructura especializada en guardar las direcciones de destino de ramas previas para predecir rápidamente el próximo destino de una rama.

- **system.cpu_cluster.cpus.branchPred.lookups**: Número de consultas al predictor de ramas.
Representa cuántas veces se solicitó al predictor que hiciera una predicción sobre una rama.

- **system.cpu_cluster.cpus.branchPred.condPredicted**: Número de ramas condicionales predichas.
Indica cuántas ramas condicionales (if, while, etc.) fueron procesadas y predichas por el branch predictor. Esto no incluye ramas no condicionales.

- **system.cpu_cluster.cpus.branchPred.condIncorrect**: Número de predicciones condicionales incorrectas. Este contador mide las veces que el predictor falló al predecir correctamente el resultado de una rama condicional.

- **system.cpu_cluster.cpus.branchPred.BTBLookups**: Número de consultas al Buffer de Tabla de Ramas (BTB). Este valor indica cuántas veces el procesador consultó esta tabla para determinar el destino de una rama.

- **system.cpu_cluster.cpus.branchPred.BTBUpdates**: Número de actualizaciones al BTB.
Cada vez que el destino de una rama cambia o se encuentra uno nuevo, el BTB se actualiza. Esto representa esas modificaciones.

- **system.cpu_cluster.cpus.branchPred.BTBHits**:Número de aciertos en el BTB.
Representa las veces que el destino de una rama se encontró correctamente en el BTB. Un número alto aquí refleja una buena eficiencia del BTB.
