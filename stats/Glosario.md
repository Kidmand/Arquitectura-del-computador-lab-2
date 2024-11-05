# Glosario

- **system.cpu_cluster.cpus.numCycles**: Número total de ciclos de reloj que la CPU uso para procesar las instrucciones.

- **system.cpu_cluster.cpus.dcache.overallHits::total**: Número total de aciertos en la caché de datos (data cache).

- **system.cpu_cluster.cpus.dcache.ReadReq.hits::total**: Número total de aciertos en la caché de datos específicamente para solicitudes de lectura.

- **system.cpu_cluster.cpus.icache.overallHits::total**: Número total de aciertos en la caché de instrucciones (instruction cache).

- **system.cpu_cluster.cpus.idleCycles**: Número total de ciclos de reloj en los que la CPU estuvo inactiva (idle), es decir, no estaba realizando ningún trabajo útil.
  - Obs: Un número elevado de ciclos inactivos puede ser un indicativo de que la CPU no está siendo utilizada de manera eficiente, ya sea por un cuello de botella en otros componentes del sistema o por una baja carga de trabajo.
