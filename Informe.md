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

Como se verá en cada gráfico, las estadísticas no cambian según el tamaño de la cache.
Esto es así ya que en nuestro programa, accedemos (lectura/escritura) secuencialmente a cada uno de los elementos de los arreglos. Por lo tanto no volveremos a necesitar un bloque al que ya hemos accedido entero, entonces, no hace falta que persistan en cache ya que no lo volveremos a necesitar. Por lo tanto aumentar el tamaño de cache no surtirá ningún efecto en nuestras estadísticas. Hacerlo nos permitiría guardar más bloques, pero no nos hace falta ya que nosotros solo necesitamos guardar uno a la vez por arreglo (por decirlo de otra manera, podríamos usar solo una línea de la cache por arreglo e ir almacenando los bloques ahí continuadamente dado que accedemos secuencialmente al arreglo como se mencionó anteriormente).

Aunque el tamaño de cache de datos no nos afecta, la cantidad de vias si. Así como en los siguientes casos de análisis.

Al considerar la cantidad de ciclos/clocks del programa, podemos ver que al variar la cantidad de vias tenemos diferentes resultados.

![Ciclos Simulados](<stats/stats-ej1-img/Ciclos Simulados.png>)

Como podemos notar, al tener 2 vías mejora el rendimiento en cuanto a la cantidad de ciclos simulados.
Pero, ¿Por qué el rendimiento es peor con una sola vía?
Esto es así ya que:

- Cada arreglo tiene 4096 elementos de 8 bytes, es decir cada uno ocupa 32kB,
- Por como están inicializados los arreglos en memoria ram, estos se encuentran uno seguido al otro, es decir está primero el arreglo X, luego el arreglo Y, y finalmente el Z.
- Como los tamaños de cache son múltiplos de 32kB (son de 8kB, 16kB, y 32kB), analizando el caso de una sola vía, tenemos que cada i-esimo elemento del arreglo X,Y y Z caen justamente en la misma linea, pisando siempre el bloque traído por el anterior arreglo.

Ahora, ¿por que el rendimiento es mejor con dos vias?
Aunque parezca que debería mejorar siempre, no es así, ya que depende de la política de reemplazo de la cache.
Por ejemplo, si la política es reemplazar el bloque más viejo, pasaría lo siguiente:

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
Como tenemos mejoras con dos vías, podemos inferir que la política de reemplazo tiene un efecto similar al segundo caso.

A su vez podemos notar que la cantidad de ciclos totales de la simulación está correlacionada con la cantidad de stalls:

![Ciclos de CPU en Stall](<stats/stats-ej1-img/Ciclos de CPU en Stall.png>)

Esto es así ya que el tiempo que se tarda en traer datos de memoria principal puede llegar a ocupar varios ciclos de clock, en los que si no hay ninguna instrucción que se pueda procesar, se stolleara el micro. Por lo tanto si ocurren mas hits en cache se traerán los datos en menos tiempo, osea en menos ciclos de clock, y por lo tanto habrá menor cantidad de ciclos de CPU inactivos/stolleados.

Notar que hay un comportamiento raro con la cache de 4 y 8 vías, las gráficas no representan lo que esperamos. Pero vamos a contar lo que esperabamos igualmente. Lo que debería pasar con 4 vías es que se reduzcan la cantinda de ciclos simulados ya que se reducen los reemplazos de bloques. Tenemos 3 arreglos, dos que leemos y 1 que escribimos de forma secuencial y en bucle en nuestro programa, por lo tanto deberíamos tener más hits en cache de datos al aumentar la cantidad de vías a 4. Y por ello la cantidad de ciclos simulados debería disminuir. Luego con 8 vías debería mantenerse igual que con 4 vías, ya que solo necesitamos 3 bloques en cache por como es nuestro programa.
La otra parte rara es que los gráficos tanto de los stall y hits están inversamente correlacionados, es decir que a más hits esperaríamos menos stall, pero eso no se ve contemplado en los gráficos, de hecho lo que se ve es todo lo contrario.

<!-- TODO:
- Mas hits totales que de lectura porque tenemos de escritura de Z.
- Con 2 vias no se notan los hits de escritura ¿ya que siempre se reemplazan?.
-->

Como dijimos, en nuestro caso, deberían aumentar los hits en cache de datos al aumentar las vías. Y por lo tanto estar la cantidad de ciclos simulados y ciclos inactivos inversamente correlacionados con la cantidad de hits en cache de datos.

![Dcache Hits](<stats/stats-ej1-img/Dcache Hits.png>)

Como podemos ver, se cumplió lo que dijimos en el caso de 1 y 2 vías.

Para el caso de 4 y 8 vías, vemos como aumenta la cantidad de hits, algo que esperabamos al tener mas vías y por como es nuestro programa, 3 arreglos, dos que leemos y 1 que escribimos y todo esto en un bucle. Exprimiendo al máximo la cache de datos.

Recordando lo que dijimos antes, con 1 vía hay constantes reemplazos, por lo tanto no deberíamos tener hits más que los valores que entran en el rango de error de la simulación. Lo que en cierta medida se cumple.
Luego para el caso de 2 vías, vemos como mejora la cantidad de hits porque justamente disminuyen los reemplazos de bloques.

Pero, ¿cuántos hits son de escritura y lectura?

![Dcache ReadReq Hits](<stats/stats-ej1-img/Dcache ReadReq Hits.png>)

Como podemos observar, la cantidad de hits de lectura es mayor a la de escritura en todos los casos.
Aproximadamente entre un 3.5% es de escritura, lo que concuerda con la proporción de nuestro código (leemos en X e Y y escribimos solo en Z).
Salvo con 2 vías donde la mayoría de los hits son de lectura. Esto es posible que sea por lo dicho anteriormente sobre la política de reemplazo de la cache. Si al haber 2 vías, se reemplazan siempre los bloques Z e Y entre si por ejemplo, entonces tendríamos este efecto.

<!-->

con el respectivo análisis, una breve
explicación de las técnicas de mejoras aplicadas en el punto e) y una comparación de
resultados con los obtenidos en los puntos c) y d). Se deben entregar en adjunto los códigos
assembler generados para los puntos a) y e).-->

### Mejorando el código de daxpy usando técnicas estáticas.

En esta parte explicaremos la mejora que introdujimos en el código usando loop and rooling. Para un mejor entendimiento de la técnica usada, analizaremos más adelante comparando los resultados como esto varía dependiedo la cantidad de desenrrollado que usamos en el código del bucle.

> LOOP AND ROOLING DE 2

```asm
    ldr x9, [x10]
    scvtf d0, x9

    mov x5, 0   // i = 0
    mov x6, 0   // x6 = 0

loop:
    cmp x5, x0           // Comparar i con N
    b.ge end             // If i >= N, end

    ldr d1, [x2, x6]     // d1 = X[i]
    ldr d2, [x3, x6]     // d2 = Y[i]

    fmul d3, d0, d1      // d3 = alpha * X[i]
    fadd d3, d3, d2      // d3 = alpha * X[i] + Y[i]
    str d3, [x4, x6]     // Z[i] = alpha * X[i] + Y[i]

    add x6, x6, #8        // x6 += 8

    ldr d4, [x2, x6]     // d4 = X[i+1]
    ldr d5, [x3, x6]     // d5 = Y[i+1]

    fmul d6, d0, d4      // d6 = alpha * X[i+1]
    fadd d6, d6, d5      // d6 = alpha * X[i+1] + Y[i+1]
    str d3, [x4, x6]     // Z[i+1] = alpha * X[i+1] + Y[i+1]

    add x5, x5, #2        // i++
    add x6, x6, #8        // x6 += 8

    b loop
end:
```

> LOOP AND ROOLING DE 4

```asm
    ldr x9, [x10]
    scvtf d0, x9

    mov x5, 0   // i = 0
    mov x6, 0   // x6 = 0

loop:
    cmp x5, x0           // Comparar i con N
    b.ge end             // If i >= N, end

    ldr d1, [x2, x6]     // d1 = X[i]
    ldr d2, [x3, x6]     // d2 = Y[i]

    fmul d3, d0, d1      // d3 = alpha * X[i]
    fadd d3, d3, d2      // d3 = alpha * X[i] + Y[i]
    str d3, [x4, x6]     // Z[i] = alpha * X[i] + Y[i]

    add x6, x6, #8       // x6 += 8

    ldr d4, [x2, x6]     // d4 = X[i+1]
    ldr d5, [x3, x6]     // d5 = Y[i+1]

    fmul d6, d0, d4      // d6 = alpha * X[i+1]
    fadd d6, d6, d5      // d6 = alpha * X[i+1] + Y[i+1]
    str d6, [x4, x6]     // Z[i+1] = alpha * X[i+1] + Y[i+1]

    add x6, x6, #8       // x6 += 8

    ldr d7, [x2, x6]     // d7 = X[i+2]
    ldr d8, [x3, x6]     // d8 = Y[i+2]

    fmul d9, d0, d7      // d9 = alpha * X[i+2]
    fadd d9, d9, d8      // d9 = alpha * X[i+2] + Y[i+2]
    str d9, [x4, x6]     // Z[i+2] = alpha * X[i+2] + Y[i+2]

    add x6, x6, #8       // x6 += 8

    ldr d10, [x2, x6]    // d10 = X[i+3]
    ldr d11, [x3, x6]    // d11 = Y[i+3]

    fmul d12, d0, d10    // d12 = alpha * X[i+3]
    fadd d12, d12, d11   // d12 = alpha * X[i+3] + Y[i+3]
    str d12, [x4, x6]    // Z[i+3] = alpha * X[i+3] + Y[i+3]

    add x6, x6, #8       // x6 += 8
    add x5, x5, #4       // i++
    b loop
end:
```

> LOOP AND ROOLING DE 8

```asm
   ldr x9, [x10]
    scvtf d0, x9

    mov x5, 0   // i = 0
    mov x6, 0   // x6 = 0

loop:
    cmp x5, x0              // Comparar i con N
    b.ge end                // If i >= N, end

    ldr d1, [x2, x6]        // d1 = X[i]
    ldr d2, [x3, x6]        // d2 = Y[i]

    fmul d3, d0, d1         // d3 = alpha * X[i]
    fadd d3, d3, d2         // d3 = alpha * X[i] + Y[i]
    str d3, [x4, x6]        // Z[i] = alpha * X[i] + Y[i]

    add x6, x6, #8          // x6 += 8

    ldr d4, [x2, x6]        // d4 = X[i+1]
    ldr d5, [x3, x6]        // d5 = Y[i+1]

    fmul d6, d0, d4         // d6 = alpha * X[i+1]
    fadd d6, d6, d5         // d6 = alpha * X[i+1] + Y[i+1]
    str d6, [x4, x6]        // Z[i+1] = alpha * X[i+1] + Y[i+1]

    add x6, x6, #8          // x6 += 8

    ldr d7, [x2, x6]        // d7 = X[i+2]
    ldr d8, [x3, x6]        // d8 = Y[i+2]

    fmul d9, d0, d7         // d9 = alpha * X[i+2]
    fadd d9, d9, d8         // d9 = alpha * X[i+2] + Y[i+2]
    str d9, [x4, x6]        // Z[i+2] = alpha * X[i+2] + Y[i+2]

    add x6, x6, #8          // x6 += 8

    ldr d10, [x2, x6]       // d10 = X[i+3]
    ldr d11, [x3, x6]       // d11 = Y[i+3]

    fmul d12, d0, d10       // d12 = alpha * X[i+3]
    fadd d12, d12, d11      // d12 = alpha * X[i+3] + Y[i+3]
    str d12, [x4, x6]       // Z[i+3] = alpha * X[i+3] + Y[i+3]

    add x6, x6, #8          // x6 += 8

    ldr d13, [x2, x6]       // d13 = X[i+4]
    ldr d14, [x3, x6]       // d14 = Y[i+4]

    fmul d15, d0, d13       // d15 = alpha * X[i+4]
    fadd d15, d15, d14      // d15 = alpha * X[i+4] + Y[i+4]
    str d15, [x4, x6]       // Z[i+4] = alpha * X[i+4] + Y[i+4]

    add x6, x6, #8          // x6 += 8

    ldr d16, [x2, x6]       // d16 = X[i+5]
    ldr d17, [x3, x6]       // d17 = Y[i+5]

    fmul d18, d0, d16       // d18 = alpha * X[i+5]
    fadd d18, d18, d17      // d18 = alpha * X[i+5] + Y[i+5]
    str d18, [x4, x6]       // Z[i+5] = alpha * X[i+5] + Y[i+5]

    add x6, x6, #8          // x6 += 8

    ldr d19, [x2, x6]       // d19 = X[i+6]
    ldr d20, [x3, x6]       // d20 = Y[i+6]

    fmul d21, d0, d19       // d21 = alpha * X[i+6]
    fadd d21, d21, d20      // d21 = alpha * X[i+6] + Y[i+6]
    str d21, [x4, x6]       // Z[i+6] = alpha * X[i+6] + Y[i+6]

    add x6, x6, #8          // x6 += 8

    ldr d22, [x2, x6]       // d22 = X[i+7]
    ldr d23, [x3, x6]       // d23 = Y[i+7]

    fmul d24, d0, d22       // d24 = alpha * X[i+7]
    fadd d24, d24, d23      // d24 = alpha * X[i+7] + Y[i+7]
    str d24, [x4, x6]       // Z[i+7] = alpha * X[i+7] + Y[i+7]

    add x6, x6, #8          // x6 += 8
    add x5, x5, #8          // i = i + 8
    b loop
end:
```

Este enfoque para loop and rooling, mejora la eficiencia del código al procesar más elementos por iteración, manteniendo un equilibrio entre el uso de registros y la reducción del overhead del bucle ya que se están haciendo menos comparaciones y saltos. Es una mejora estática que optimiza el rendimiento sin requerir cambios en el hardware o en la lógica del programa.

Ahora veamos algunos gráficos que representan los resultados obtenidos con esta mejora haciendo loop and rooling de 2, 4 y 8.

![Ciclos Simulados](<stats/stats-ej1-e-img/Ciclos Simulados.png>)

Como podemos ver en este gŕafico, existe una mejora significativa en cuanto a los ciclos en el caso del código original (sin loop and rooling) respecto del código mejorado usando la técnica de loop and rooling de 2, 4 y 8 respectivamente. También podemos notar que el caso de 2 representa la mejora más significativa en cuanto a ciclos. Según lo que analizamos, concluímos que debería haber una mejora incluso mayor o igual (menor o igual a cantidad de ciclos), pero nunca empeorar en el loop and rooling de 4 o incluso 8, ya que estamos evitando los saltos. Este comportamiento es lo que esperábamos, pero no está representado por los gráficos, lo cual es algo extraño.

![Ciclos de CPU en Stall](<stats/stats-ej1-e-img/Ciclos de CPU en Stall.png>)

De manera similar en este gráfico lo que esperábamos era tener una menor cantidad de stalls a medidad que el loop and roolign aumentara.
Cosa que al igual que antes los gráficos no están representando esta situación, lo que también es algo muy extraño.  
Porque además no solo que aumenta entre los casos de 2, 4 y 8, sino que se está teniendo un comportamiento incluso peor en en los casos de 4 y 8 con respecto al código original (sin loop and rooling). Lo cual es algo aún más extraño.

![Dcache Hits](<stats/stats-ej1-e-img/Dcache Hits.png>)

Por otra parte, notemos que este gráfico sí representa lo que esperábamos (aunque seguimos teniendo valores en el margen de error de GEM5) por lo cual sólo la parte del código sin loop and rooling (loop and rooling de 0) representa correctamente los resultados obtenidos, lo cual puede entenderse fácilmente debido a que una cache de dos vía se dan muchos más hits y no se tiene que hacer un miss por cada acceso.
