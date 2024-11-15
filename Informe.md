# Arquitectura de Computadoras - 2024

## Informe Lab2: Análisis de microarquitecturas

## Integrantes

- Alumno
- Alumno
- Alumno

## Ejercicio 1

Código:

```asm
    ldr x5, [x10]
    scvtf d0, x5

    mov x5, 0 // i = 0
    mov x6, 0 // x6 = 0
loop:
    cmp x5, x0
    b.ge end   // if i >= N, end

    ldr d1, [x2, x6] // d1 = X[i]
    ldr d2, [x3, x6] // d2 = Y[i]

    fmul d3, d0, d1 // d3 = alpha * X[i]
    fadd d3, d3, d2 // d3 = alpha * X[i] + Y[i]

    str d3, [x4, x6] // Z[i] = alpha * X[i] + Y[i]

    add x5, x5, 1 // i++
    add x6, x6, 8 // x6 += 8
    b loop
end:
```

<!-- TODO:
- Gráficos de cantidad de stalls y numero de ciclos correlacionados. (+stall -> +cilos)
- El tamaño de cache no influye ya que no se vuelven a leer los datos de los arreglos.
- Un array entero tiene 32KB = 4096 * 8B
- Una linea de cache tiene 64B
-->

Como se vera en cada gráfico, las estadísticas no cambian según el tamaño de la cache.
Esto es así ya que en nuestro programa, accedemos (lectura/escritura) secuencialmente a cada uno de los elementos de los arreglos. Por lo tanto no volveremos a necesitar un bloque al que ya hemos accedido entero, entonces, no hace falta que persistan en cache ya que no lo volveremos a necesitar. Por lo tanto aumentar el tamaño de cache no surtirá ningún efecto en nuestras estadísticas. Hacerlo nos permitiría guardar mas bloques, pero no nos hace falta ya que nosotros solo necesitamos guardar uno a la vez por arreglo.

Aunque el tamaño de cache de datos no nos afecta, la cantidad de vias si. Así como en los siguientes casos de análisis.

Al considerar la cantidad de ciclos/clocks del programa, podemos ver que al variar la cantidad de vias tenemos diferentes resultados.

![Ciclos Simulados](<stats/stats-ej1-img/Ciclos Simulados.png>)
Como podemos notar, al tener 2 vias mejora el rendimiento en cuanto a la cantidad de ciclos simulados.
Pero, ¿por que el rendimiento es peor con una sola via?
Esto es así ya que:

- Cada arreglo tiene 4096 elementos de 8 bytes, es decir cada uno ocupa 32kB,
- Por como están inicializados los arreglos en memoria ram, estos se encuentran uno seguido al otro, es decir esta primero el arreglo X, luego el arreglo Y, y finalmente el Z.
- Como los tamaños de cache son múltiplos de 32kB (son de 8kB, 16kB, y 32kB), analizando el caso de una sola via, tenemos que cada i-esimo elemento del arreglo X,Y y Z caen justamente en la misma linea, pisando siempre el bloque traído por el anterior arreglo.

Ahora,  ¿por que el rendimiento es mejor con dos vias?
Aunque parezca que debería mejorar siempre, no es así, ya que depende de la política de reemplazo de la cache.
Por ejemplo, si la política es reemplazar el bloque mas viejo, pasaría lo siguiente:

| Buscamos un bloque de | Arrays cacheados |
| --------------------- | ---------------- |
| de X (Miss)           | X                |
| de Y (Miss)           | X, Y             |
| de Z (Miss)           | Z, Y             |
| de X (Miss)           | Z, X             |
| de Y (Miss)           | Y, X             |
| de Z (Miss)           | Y, Z             |
Como podemos observar, siempre se reemplaza el bloque que se querrá buscar en el siguiente acceso. Por lo que nunca tendremos hits.
En cambio si la política es reemplazar el bloque mas nuevo:

| Buscamos un bloque de | Arrays cacheados |
| --------------------- | ---------------- |
| de X (Miss)           | X                |
| de Y (Miss)           | X, Y             |
| de Z (Miss)           | X, Z             |
| de X (Hit)            | X, Z             |
| de Y (Miss)           | X, Y             |
| de Z (Miss)           | X, Z             |

Como podemos ver, acceder a X siempre daría Hit luego de traer por primera vez cada bloque correspondiente ya que nunca se lo reemplazaría.
Como tenemos mejoras con dos vias, podemos inferir que la política de reemplazo tiene un efecto similar al segundo caso.

A su vez podemos notar que la cantidad de ciclos totales de la simulación esta correlacionada con la cantidad de stalls:
![Ciclos de CPU en Stall](<stats/stats-ej1-img/Ciclos de CPU en Stall.png>)
Esto es así ya que el tiempo que se tarda en traer datos de memoria principal puede llegar a ocupar varios ciclos de clock, en los que si no hay ninguna instrucción que se pueda procesar, se stolleara el micro. Por lo tanto si ocurren mas hits en cache se traerán los datos en menos tiempo, osea en menos ciclos de clock, y por lo tanto habrá menor cantidad de ciclos de CPU inactivos/stolleados.

Notar que hay un comportamiento raro con la cache de 4 y 8 vias, las graficas no representan lo que esperamos. Pero vamos a contar lo que esperabamos igualmente. Lo que deberia pasar con 4 vias es que se reduzcan la cantinda de ciclos simulados ya que se reducen los reemplazos de bloques. Tenemos 3 arreglos, dos que leemos y 1 que escribimos de forma secuencial y en bucle en nuestro programa, por lo tanto deberíamos tener mas hits en cache de datos al aumentar la cantidad de vias a 4. Y por ello la cantidad de ciclos simulados debería disminuir. Luego con 8 vias deberia mantenerse igual que con 4 vias, ya que solo necesitamos 3 bloques en cache por como es nuestro programa.

<!-- TODO:
- Mas hits totales que de lectura porque tenemos de escritura de Z.
- Con 2 vias no se notan los hits de escritura ¿ya que siempre se reemplazan?.
-->

Como dijimos, en nuestro caso, deberían aumentar los hits en cache de datos al aumentar las vias. Y por lo tanto estar la cantidad de ciclos simulados y ciclos inactivos inversamente correlacionados con la cantidad de hits en cache de datos.

![Dcache Hits](<stats/stats-ej1-img/Dcache Hits.png>)
Como podemos ver, se cumplió lo que dijimos en el caso de 1 y 2 vias.

Pero tenemos un problema con 4 y 8 vias, la correlación entre los gráficos no es inversa.

<!-- FIXME: COMPLETAR PARA CASO DE 4 Y 8 VIAS ... -->

Recordando lo que dijimos antes, con 1 via hay constantes reemplazos, por lo tanto no deberíamos tener hits mas que los valores que entran en el rango de error de la simulación. Lo que en cierta medida se cumple.
Luego para el caso de 2 vias, vemos como mejora la cantidad de hits porque justamente disminuyen los reemplazos de bloques.

Pero, ¿cuantos hits son de escritura y lectura?

![Dcache ReadReq Hits](<stats/stats-ej1-img/Dcache ReadReq Hits.png>)

Como podemos observar, la cantidad de hits de lectura es mayor a la de escritura en todos los casos.
Aproximadamente entre un 3.5% es de escritura, lo que concuerda con la proporción de nuestro código (leemos en X e Y y escribimos solo en Z).
Salvo con 2 vias donde la mayoría de los hits son de lectura. Esto es posible que sea por lo dicho anteriormente sobre la política de reemplazo de la cache. Si al haber 2 vias, se reemplazan siempre los bloques Z e Y entre si por ejemplo, entonces tendríamos este efecto.
