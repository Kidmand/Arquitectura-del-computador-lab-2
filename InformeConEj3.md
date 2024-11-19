# Arquitectura de Computadoras - 2024

## Informe Lab2: Análisis de microarquitecturas

## Integrantes

- Viola Lugo Ramiro
- Giménez García Daián
- Viola Di Benedetto Matias

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

Ahora, ¿por que el rendimiento es mejor con dos vías?
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

Notar que hay un comportamiento raro con la cache de 4 y 8 vías, las gráficas no representan lo que esperamos. Pero vamos a contar lo que esperábamos igualmente. Lo que debería pasar con 4 vías es que se reduzcan la cantidad de ciclos simulados ya que se reducen los reemplazos de bloques. Tenemos 3 arreglos, dos que leemos y 1 que escribimos de forma secuencial y en bucle en nuestro programa, por lo tanto deberíamos tener más hits en cache de datos al aumentar la cantidad de vías a 4. Y por ello la cantidad de ciclos simulados debería disminuir. Luego con 8 vías debería mantenerse igual que con 4 vías, ya que solo necesitamos 3 bloques en cache por como es nuestro programa.
La otra parte rara es que los gráficos tanto de los stall y hits están inversamente correlacionados, es decir que a más hits esperaríamos menos stall, pero eso no se ve contemplado en los gráficos, de hecho lo que se ve es todo lo contrario.

Como dijimos, en nuestro caso, deberían aumentar los hits en cache de datos al aumentar las vías. Y por lo tanto estar la cantidad de ciclos simulados y ciclos inactivos inversamente correlacionados con la cantidad de hits en cache de datos.

![Dcache Hits](<stats/stats-ej1-img/Dcache Hits.png>)

Como podemos ver, se cumplió lo que dijimos en el caso de 1 y 2 vías.

Para el caso de 4 y 8 vías, vemos como aumenta la cantidad de hits, algo que esperábamos al tener mas vías y por como es nuestro programa, 3 arreglos, dos que leemos y 1 que escribimos y todo esto en un bucle. Exprimiendo al máximo la cache de datos.

Recordando lo que dijimos antes, con 1 vía hay constantes reemplazos, por lo tanto no deberíamos tener hits más que los valores que entran en el rango de error de la simulación. Lo que en cierta medida se cumple.
Luego para el caso de 2 vías, vemos como mejora la cantidad de hits porque justamente disminuyen los reemplazos de bloques.

Pero, ¿cuántos hits son de escritura y lectura?

![Dcache ReadReq Hits](<stats/stats-ej1-img/Dcache ReadReq Hits.png>)

Como podemos observar, la cantidad de hits de lectura es mayor a la de escritura en todos los casos.
Aproximadamente entre un 35% es de escritura, lo que concuerda con la proporción de nuestro código (leemos en X e Y y escribimos solo en Z).
Salvo con 2 vías donde la mayoría de los hits son de lectura. Esto es posible que sea por lo dicho anteriormente sobre la política de reemplazo de la cache. Si al haber 2 vías, se reemplazan siempre los bloques Z e Y entre si por ejemplo, entonces tendríamos este efecto.

### Mejorando el código de daxpy usando técnicas estáticas.

En esta parte explicaremos la mejora que introdujimos en el código usando loop unrolling. Para un mejor entendimiento de la técnica usada, analizaremos más adelante comparando los resultados como esto varía dependiedo la cantidad de desenrrollado que usamos en el código del bucle.

> LOOP UNROLLING DE 2

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

> LOOP UNROLLING DE 4

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

> LOOP UNROLLING DE 8

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

Este enfoque para loop unrolling, mejora la eficiencia del código al procesar más elementos por iteración, manteniendo un equilibrio entre el uso de registros y la reducción del overhead del bucle ya que se están haciendo menos comparaciones y saltos. Es una mejora estática que optimiza el rendimiento sin requerir cambios en el hardware o en la lógica del programa.

Ahora veamos algunos gráficos que representan los resultados obtenidos con esta mejora haciendo loop unrolling de 2, 4 y 8.

![Ciclos Simulados](<stats/stats-ej1-e-img/Ciclos Simulados.png>)

Como podemos ver en este gráfico, existe una mejora significativa en cuanto a los ciclos en el caso del código original (sin loop unrolling) respecto del código mejorado usando la técnica de loop unrolling de 2, 4 y 8 respectivamente. También podemos notar que el caso de 2 representa la mejora más significativa en cuanto a ciclos. Según lo que analizamos, concluimos que debería haber una mejora incluso mayor o igual (menor o igual a cantidad de ciclos), pero nunca empeorar en el loop unrolling de 4 o incluso 8, ya que estamos evitando los saltos. Este comportamiento es lo que esperábamos, pero no está representado por los gráficos, lo cual es algo extraño.

![Ciclos de CPU en Stall](<stats/stats-ej1-e-img/Ciclos de CPU en Stall.png>)

De manera similar en este gráfico lo que esperábamos era tener una menor cantidad de stalls a medidad que el loop unrollign aumentara.
Cosa que al igual que antes los gráficos no están representando esta situación, lo que también es algo muy extraño.  
Porque además no solo que aumenta entre los casos de 2, 4 y 8, sino que se está teniendo un comportamiento incluso peor en los casos de 4 y 8 con respecto al código original (sin loop unrolling). Lo cual es algo aún más extraño.
Igualmente podemos ver algo que esperábamos y es que la cantidad de stalls disminuye para el caso de loop unrroling de 2.

![Dcache Hits](<stats/stats-ej1-e-img/Dcache Hits.png>)

Por otra parte, notemos que este gráfico sí representa lo que esperábamos (aunque seguimos teniendo valores en el margen de error de GEM5) por lo cual sólo la parte del código sin loop unrolling (loop unrolling de 0) representa correctamente los resultados obtenidos, lo cual puede entenderse fácilmente debido a que una cache de dos vías se dan muchos más hits y no se tiene que hacer un miss por cada acceso.

### Analizando y ejecutando el código anterior usando un procesador out-of-order.

Como veremos en estos gráficos, se representa esquemáticamente la diferencia entre un procesador in-order y uno out-of-order.

![Ciclos Simulados](<stats/stats-ej1-f-img/Ciclos Simulados.png>)

Analizando, concluimos que el comportamiento que esperábamos, en este caso sí se está mostrando correctamente, dado que en un procesador out-of-order, el ordenamiento de las instrucciones es automático/dinámico, es decir se ejecuta de una manera más óptima. Y esta mejora es para todos los casos, tenga o no loop unrolling. Debido a que las únicas mejoras que le hicimos al código fue usando solo las técnicas de loop unrolling, register remainig y ninguna más.

![Ciclos de CPU en Stall](<stats/stats-ej1-f-img/Ciclos de CPU en Stall.png>)

Al igual que antes, podemos ver una disminución muy significativa en cuanto a los stalls en los distintos casos, esto también puede entenderse fácilmente debido a que en el procesador out-of-order al tener un ordenamiento bastante óptimo, ejecuta de manera eficiente las instrucciones reduciendo de esta manera, la cantidad de stalls. Como se mencionó anteriormente, esto no es independiente para cada caso, sino que en todos los casos el comportamiento es similar. Siguiendo con esta misma idea, nos damos cuenta que para este procesador out-of-order, puede soportar mejores técnicas de optimización que las que aplicamos al código.
Por esta razón el comportamiento de los resultados tanto de los ciclos como el de los stalls es similar para los casos de loop unrolling de 2, 4, 8 y también para el caso del código sin loop unrolling (loop unrolling de 0).

![Dcache Hits](<stats/stats-ej1-f-img/Dcache Hits.png>)

En base a lo analizado, creemos que el procesador que estamos usando para simular soporta (loop unrolling). Por esta razón podemos ver en el gráfico que el caso del código sin loop unrolling, la cantidad de hits es mayor para los casos del código con loop unrolling de 2, 4 y 8. De esta manera, deducimos que para el caso del código sin loop unrolling se está haciendo lo más óptimo posible, y en los otros no, debido a que está hecho de forma estática.

## Ejercicio 2

En este ejercicio vamos a analizar como se comporta la cache para un código más complejo de simulación física sobre la variación de calor con respecto a una placa de material uniforme y una fuente de calor.
Para esto tradujimos el código entregado por la cátedra al siguiente assembly:

```asm
scvtf D0, x4
MOV X8, #0                      // X8 = i Condición para salto
MUL X10, X0, X0                 // X10 = N*N

loop_init_t_amb:
    CMP X8, X10
    B.GE loop_init_t_amb_end    // if i >= N, end
    STR D0, [X1, X8, LSL #3]    // x[i] = t_amb
    ADD X8, X8, #1              // i(X8) = i + 1
    B loop_init_t_amb
loop_init_t_amb_end:

scvtf D1, x7
MADD X11, X5, X0, X6            // X11 = fc_x(X5) * N(X0) + fc_y(X6)
STR D1, [X1, X11, LSL #3]       // x[fc_x*N+fc_y] = fc_temp(D1);

MOV X8, #0                      // X8 = k
MOV X9, #0                      // X9 = i
MOV X10, #0                     // X10 = j
MOV X25, #0                     // X25 = h
MOV X11, X3                     // X11 = (n_iter = 10)
MOV X12, X0                     // X12 = (N = 64)
MUL X26, X0, X0                 // X26 = N*N
MADD X14, X5, x0, X6            // X14 = fc_x(X5) * N(X0) + fc_y(X6) (ie, el punto de calor)
FMOV D8, #4.0                   // D8  = 4

loop_k:
    CMP X8, X11
    B.GE loop_k_end                                             // if k >= n_iter, go end
        MOV X9, #0                                              // i = 0
        loop_i:
            CMP X9, X12
            B.GE loop_i_end                                     // if i >= N, go end
                MOV X10, #0                                     // j = 0
                loop_j:
                    CMP X10, X12
                    B.GE loop_j_end                             // if j >= N, go end
                        MADD X13, X9, X12, X10                  // X13 = i(X9) * N(X12) + j(X10)
                        CMP X13, X14
                        B.EQ loop_j_end_if                      // if (i*N + j) == (fc_x*N + fc_y), end
                            MOVI D2, #0                         // SUM = 0.0


                            //---------- Casilla abajo ---------\\
                            ADD X16, X9, #1
                            CMP X16, X12
                            B.GE casilla_abajo                  // if i + 1 < N, go end
                                MADD X17, X16, X12, X10         // X17 = (i+1)(X16) * N(X12) + j(X10)
                                LDR D3, [X1, X17, LSL #3]       // D3 = x[(i+1)*N + j]
                                FADD D2, D2, D3                 // SUM = SUM + x[(i+1)*N + j]
                                B casilla_abajo_end
                            casilla_abajo:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_abajo_end:
                            //-----------------------------------\\


                            //---------- Casilla arriba ---------\\
                            SUB X18, X9, #1
                            CMP X18, XZR
                            B.LT casilla_arriba                 // if i - 1 >= 0, go end
                                MADD X19, X18, X12, X10         // X19 = (i-1)(X18) * N(X12) + j(X10)
                                LDR D4, [X1, X19, LSL #3]       // D4 = x[(i-1)*N + j]
                                FADD D2, D2, D4                 // SUM = SUM + x[(i-1)*N + j]
                                B casilla_arriba_end
                            casilla_arriba:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_arriba_end:
                            //-----------------------------------\\


                            //--------- Casilla derecha ---------\\
                            ADD X20, X10, #1
                            CMP X20, X12
                            B.GE casilla_derecha                // if j + 1 < N, go end
                                MADD X21, X9, X12, X20          // X21 = (i)(X16) * N(X12) + (j+1)(X10)
                                LDR D5, [X1, X21, LSL #3]       // D5 = x[i*N + j+1]
                                FADD D2, D2, D5                 // SUM = SUM + x[i*N + j+1]
                                B casilla_derecha_end
                            casilla_derecha:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_derecha_end:
                            //----------------------------------\\


                            //-------- Casilla izquierda -------\\
                            SUB X22, X10, #1
                            CMP X22, XZR
                            B.LT casilla_izquierda              // if j - 1 >= 0, go end
                                MADD X23, X9, X12, X22          // X23 = (i)(X16) * N(X12) + (j-1)(X10)
                                LDR D6, [X1, X23, LSL #3]       // D6 = x[i*N + j-1]
                                FADD D2, D2, D6                 // SUM = SUM + x[i*N + j-1]
                                B casilla_izquierda_end
                            casilla_izquierda:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_izquierda_end:
                            //----------------------------------\\


                            //-------- Guardar en x_tmp --------\\
                            FDIV D2, D2, D8                     // SUM = SUM / 4
                            MADD X24, X9, X12, X10              // X24 = i(X9) * N(12) + j(10)
                            STR D2, [X2, X24, LSL #3]           // x_tmp[i*N + j] = SUM
                            //----------------------------------\\

                    loop_j_end_if:
                        ADD  X10, X10, #1                       // j(X10) = j + 1
                        B loop_j

                loop_j_end:
                    ADD X9, X9, #1                              // i(X9) = i + 1
                    B loop_i

        loop_i_end:

            //-------- Cargar valores de x_tmp a x --------\\
            MOV X25, #0                                         // h = 0
            loop_h:
                CMP X25, X26
                B.GE loop_h_end                                 // if h >= N*N, go end
                    CMP X25, X14
                    B.EQ loop_h_end_if                          // if h == (fc_x*N + fc_y), go end
                        LDR D7, [X2, X25, LSL #3]               // D7 = x_tmp[h]
                        STR D7, [X1, X25, LSL #3]               // x[h] = x_tmp[h]
                    loop_h_end_if:
                    ADD X25, X25, #1                            // h = h + 1
                    B loop_h

            loop_h_end:
            //----------------------------------------------\\

            ADD X8, X8, #1                                      // k(X8) = k + 1
            b loop_k
loop_k_end:
```

Empecemos analizando este código, donde tenemos dos arreglos, los cuales vamos leyendo y escribiendo, por lo que tendremos un comportamiento similar al ejercicio 1 en las cuales los bloques serán reemplazados sin aprovechar al máximo la cache. Siguiendo con esta idea, al tener una cache asociativa de 2 vías y 2 arreglos podremos aprovechar un mejor uso de la cache teniendo menos reemplazos.

Veamos el gráfico que representa esta situación con la cantidad de ciclos simulados.

![Ciclos Simulados](<stats/stats-ej2/ej2-c-img/Ciclos Simulados.png>)

Notemos que el gráfico demuestra esquemáticamente lo mencionado anteriormente, al ver que existe una mejora de una cache de 1 vía a una de 2.

Observemos que en el gráfico la cantidad de ciclos simulados en 2, 4 y 8 vías son similares.

Analicemos esto en detalle:

Por como es nuestro programa, estamos accediendo siempre por cada casilla del arreglo a las posiciones izquierda, derecha, arriba y abajo del arreglo, por esta razón simplemente nos alcanza con que la cache tenga en el mejor de los casos 3 bloques y en el peor de los casos 4 bloques, por lo que cada 8 iteraciones se harán miss, ya que una línea de cache tiene 64 bytes y las palabras de nuestro arreglo son de 8 bytes. Son 3 bloques porque necesitamos 1 bloque para la casilla de arriba, un bloque para la casilla de abajo y un bloque para la casilla de la izquierda y la derecha y en el peor de los casos un bloque para cada uno (i.e dos bloques), y como nos movemos secuencialmente en el arreglo también lo hacemos en los 3/4 bloques, es decir que accedemos alas palabras de los bloques de manera secuencial
Los bloques pueden estar sobre una misma vía o pueden estar sobre vías distintas. Por esta razón, al dividir la cache en más vías, el comportamiento sigue siendo el mismo que una cache asociativa por conjuntos de dos vías.

Como dijimos en un principio con las caches de 2, 4 y 8 vías, las cantidades de ciclos simulados son similirares debido a que tenemos siempre una cache de 32KB y aumentar la cantidad de vías reduce el tamaño de la cahce de cada vía, pero en el peor de los casos tendremos un tamaño de 32KB/8 = 4KB que es mayor al margen de lo que necesitamos.

Además como también estamos accediendo al arreglo original (x) y luego al arreglo temporal (x_temp), siempre tenemos que tener al menos dos vías para ver una mejora en cuanto ciclos.

![Ciclos de CPU en Stall](<stats/stats-ej2/ej2-c-img/Ciclos de CPU en Stall.png>)

Como podemos ver la cantidad de stall disminuye significativamente teniendo varias vías (2, 4, 8) algo que está correlacionado con la cantidad de ciclos simulados mostrado en el gráfico anterior.

![Dcache Hits](<stats/stats-ej2/ej2-c-img/Dcache Hits.png>)

Al igual que el gráfico de stalls, también podemos ver una correlación inversa con respecto al gráfico de ciclos simulados, ya que estamos aprovechando mejor la cache.

![Dcache ReadReq Hits](<stats/stats-ej2/ej2-c-img/Dcache ReadReq Hits.png>)

Comparando este gráfico con el anterior notamos una relación que nos permite identificar aproximadamente 5 lecturas y 2 de escrituras por cada casillas (teniendo en cuenta lo dos arreglos). Esto sería un 70% más de veces de hits de lectura que de escritura, algo que se relaciona con nuestro programa dado que por cada casilla que no es borde leemos las 4 casillas adyacentes y escribimos una vez el arreglo temporal.
Luego se nos suma una escritura y una lectura por cada casilla dado que copiamos el arreglo temporal al arreglo original.

### Análisis de los predictores de saltos.

Para el primer bucle con la etiqueta `loop_init_t_amb` nos conviene claramente el predictor local dado que se equivoca una vez al salir, dependiendo obviamente de como esté inicializado el estado, de igual forma en el peor caso fallaría dos veces.

Para el segundo bucle con la etiqueta `loop_k`, también nos conviene el predictor local. Misma explicación que en el anterior.

Para el tercer bucle con la etiqueta `loop_i` anidado al bucle con la etiqueta `loop_k`, también nos conviene el predictor local. Misma explicación que lo anterior.

Para el cuarto bucle con la etiqueta `loop_j` anidado al bucle con la etiqueta `loop_i`, también nos conviene el predictor local. Misma explicación que lo anterior.

Para el primer `if` dentro del bucle con la etiqueta `loop_j`, es decir `if ((i * N + j) != (FC_X * N + FC_Y))` nos conviene el predictor local debido a que la fuente de calor es única y estática por lo que falla una vez.

Para los `if` que verifican si las casillas adyacentes son un borde nos conviene usar predictor global, dado que si la casilla tiene un borde superior, no va a tener una casilla borde inferior y viceversa. Luego si tenemos una casilla con borde a la derecha, no tendrá un borde a la izquierda y viceversa. Y dado que esto se repite todo el tiempo, nos da a entender que el mejor predictor a usar es el global para este caso.

```asm
sum = 0;
if (i + 1 < N) // Casilla abajo
    sum = sum + x[(i + 1) * N + j];
else
    sum = sum + T_AMB;

if (i - 1 >= 0) // Casilla arriba
    sum = sum + x[(i - 1) * N + j];
else
    sum = sum + T_AMB;

if (j + 1 < N) // Casilla derecha
    sum = sum + x[i * N + j + 1];
else
    sum = sum + T_AMB;

if (j - 1 >= 0) // Casilla izquierda.
    sum = sum + x[i * N + j - 1];
else
    sum = sum + T_AMB;
```

El último bucle con la etiqueta `loop_h` que está anidado al bucle con la etiqueta `loop_k` nos conviene el predictor local, y el `if` que está dentro de este bucle, también nos conviene un predictor local, dado que se equivoca una vez al salir, dependiendo obviamente de como esté inicializado el estado, de igual forma en el peor caso fallaría dos veces.
Para el caso del `if`, este fallaría una vez porque compara la coordenadas de la fuente y sería el peor caso.

### Usando predictor por torneos y comparando resultados con el predictor local.

En esta parte se pretende mostrar la diferencia en cuanto a eficiencia de los distintos predictores de saltos (local y por torneo) y analizar esta mejora y porqué se produce, para ello primero vamos a hacer un análisis no tan exhaustivo y de manera manual para después comparar con los resultados de la simulación.

Los cálculos que hicimos para un predictor local fueron:

- Aciertos predictor = 4095+9+(10x(63+64x63+64x64−1+(64x64−1−64)x4+(64x64−1)x2)) = 329144
- Fallas predictor = 1+1+10x(1+64+1+64x4+1+1) = 3242
- Predicciones totales = (3242 + 329144) = 332386

**4095+9+(10x(63+64x63+64x64−1+(64x64−1−64)x4+(64x64−1)x2)):**

- 4095 aciertos del bucle de inicialización.
- 9 aciertos del bucle con la etiqueta `loop_k`.
- Ahora veamos los bucles anidados, por eso se multiplica por 10. Tenemos 63 aciertos para el primer bucle anidado, y (64x63) del segundo bucle anidado.
- Se tienen (64x64 - 1) = 4095 aciertos del `if` dentro del bucle anidado `loop_j`.
- Se tiene (64x64−1−64) aciertos por cada `if` que verifican los bordes, y como son 4 se multiplica por 4. (Aclaración: se resta 1 por cada falla en la que se encuentra la fuente de calor y se le resta 64 por los bordes).
- luego tenemos el bucle con la etiqueta `loop_h` anidado al bucle con la etiqueta `loop_k` que tiene (64x64−1) aciertos.
- Dentro del bucle con la etiqueta `loop_h` se encuentra un `if` que acierta (64x64−1) veces.

**1+1+10x(1+64+1+64x4+1+1):**

- 1 falla del bucle de inicialización.
- 1 falla del bucle con la etiqueta `loop_k`.
- Ahora veamos los bucles anidados, por eso se multiplica por 10. Tenemos 1 falla para el primer bucle anidado, y 64 del segundo bucle anidado.
- Se tiene 1 falla del `if` dentro del bucle anidado `loop_j` porque hay una única fuente y es estática.
- Se tiene 64 fallas por cada `if` que verifican los bordes, y como son 4 se multiplica por 4.
- luego tenemos el bucle con la etiqueta `loop_h` anidado al bucle con la etiqueta `loop_k` que falla una vez.
- Dentro del bucle con la etiqueta `loop_h` se encuentra un `if` que falla una vez.

El mis Rate del predictor local nos quedaría: 3242/332386 = 0,00975372

Ahora analicemos el predictor por torneo considerando lo que pensamos anteriormente, referido al que el predictor global andaría mejor dentro de los if que están dentro del bucle con la etiqueta `loop_j`.
Básicamente lo que hicimos en este fue cambiar el predictor de los if mencionados de local a global quedándonos cuentas similares, cambiando lo siguiente:

- Predictor global (64x64−1)x4
- Predictor local (64x64−1−64)x4

Quedando la fórmula para calcular los aciertos de la siguiente manera:

- 4095+9+(10x(63+64x63+64x64−1+(64x64−1)x4+(64x64−1)x2)) = 331704

De forma similar usando el predictor global reduce las fallas quedando de la siguiente manera:

- Predictor global (1+64+1+4+1+1)
- Predictor local (1+64+1+64x4+1+1)

Quedando la fórmula para calcular las fallas:

- 1+1+10x(1+64+1+4+1+1) = 722

El mis Rate del predictor por torneos nos quedaría: 722/(331704 + 722) = 0,0022

Como conclusión de estos resultados vemos que el predictor por torneo nos da una mejor predicción de los saltos frente al predictor local.

Los resultados obtenidos en la simulación son:

![Miss Rate](<stats/stats-ej2/ej2-d-img/Miss Rate.png>)

Como se puede ver en este gráfico, existe una mejora en términos del miss Rate del predictor por torneo frente al predictor local.

La razón es la siguiente: Nuestro código traducido mezcla tanto bucles como `if`, según nuestros análisis en la mayoría de los casos conviene un predictor local para los bucles y un predictor global para los `if`. Con esto en mente, como se mencionó anteriormente, nuestro código cuenta con bucles e `if`, por lo que nos conviene combinar un predictor local y uno global. Si usamos solo un predictor local, fallaríamos muchas veces para los `if` que están dentro del bucle con la etiqueta `loop_j`, es decir que se aumentaría la cantidad de fallas debido al fallo de predicción y por ende el miss Rate. Por otra parte si usamos el predictor por torneo que está compuesto por un predictor global y uno local, a simple vista podríamos pensar que es claro que sería el mejor predictor, pero nos está faltando algo muy importante. ¿Por qué es mejor este predictor?, podríamos llegar a pensar que el hecho mismo de elegir que predictor usar (global y local hablando del predictor por torneo) conllevaría más gastos de ciclos, pero esto en realidad no nos afecta tanto como lo haría predecir mal el salto. Y esto en realidad reduce el miss Rate haciéndolo por supuesto más eficiente, debido a que en cada momento en el que hay un salto ya sea por `if` o por bucle, siempre estamos eligiendo el mejor predictor, lo cual es beneficioso para nuestro código dado que combina predictores globales y locales.

Cabe mencionar que este gráfico si representa lo que esperábamos, por supuesto siempre manteniéndonos al margen de que nuestro código combina `if` y bucles, y según nuestros análisis también combina el uso de predictores globales y locales. Notemos sin embargo que existe una diferencia en el predictor local según los resultados de la simulación con respecto a los calculados por nosotros, dándonos una diferencia insignificante lo cual puede suceder por dos motivos:

- El margen de error de GEM5.
- El predictor local puede llegar a funcionar mejor para algunos casos que quizás no estemos contemplando.

### Utilizando procesador out-of-order con predictor de salto.

Analizando nuestro programa de la simulación física y en base a los resultados anteriores, nos damos cuenta que justamente usar un predictor por torneo mejora la predicción de los saltos para los `if` que están dentro del bucle con la etiqueta `loop_j` (verificación de casillas bordes).
A continuación se presentan las diferencias que se dan al usar un procesador out-of-order. En este caso el código será ejecutado en un orden distinto debido al reordenamiento para mejorar la eficiencia, pero esto no conlleva necesariamente a que haya una mejora en cuanto a las predicciones de saltos y/o la eliminación de saltos de los `if` mencionados, dado que deben ejecutarse si o si, por lo que el predictor por torneo seguirá eligiendo el predictor global para estos casos, manteniendo así la misma eficiencia para predecir los saltos y por ende mantener el mismo miss Rate.

Veamos los resultados obtenidos al correr la simulación.

![Miss Rate por Predictor de saltos](<stats/stats-ej2/ej2-e-img/Miss Rate por Predictor de saltos.png>)

Como se puede observar, el miss Rate sigue siendo el mismo tanto para el procesador out-of-order como el in-order con un predictor por torneo. (Notar que se agregó también el miss Rate del procesador in-order con predictor local para tener una mejor referencia de cuánto mejora con un predictor por torneo ya sea en un procesador out-of-order o in-order).

![Ciclos Simulados](<stats/stats-ej2/ej2-e-img/Ciclos Simulados.png>)

Vale la pena destacar la cantidad de ciclos simulados según cada caso, en donde podemos observar una mejora abismal del procesador out-of-order frente al in-order, esto se debe a que aprovechamos al máximo la cantidad de instrucciones ejecutadas reduciendo significativamente la cantidad de stalls (tiempo de no hacer nada en el micro). También se puede observar que existe una mejora de un predictor local a uno por torneo en un procesador in-order, aunque la diferencia no se llega a notar en el gráfico, ésta es aproximadamente de 13.000 ciclos, y se debe a los casos de fallas por una mala predicción del predictor local.

### Ejercicio 3

En este ejercicio vamos a analizar como varían las distintas estadísticas y eficiencia, depenendiendo del procesador que usemos ya sea in-roder o out-of-order.
También cuanto mejora o empeora usando la técnica de mejora de eliminar saltos mediante una nueva istrucción la cual es `CSEL`. 

![Ciclos Simulados](<stats/stats-ej3-img/Ciclos SImulados.png>)

Como podemos ver en esta gráfica, hay una clara diferencia entre el procesador in-order frente al out-of-order. Esto ya se explicó en el ejercicio 2. El otro aspecto a considerar es el cambio entre usar la nueva instrucción `CSEL`. Como se puede apreciar, existe una mejora significativa usando la instrucción `CSEL`, también se puede observar una mejora usando dicha instrucción en el porcesador out-of-order frente al in-order.  

<!-- NOTE: Chequear esto
Notar que si implementamos las instrucciones CSEL, inevitablemente siempre vamos acceder a la memoria en ambos casos, tanto si el if falla como si no. 
Es decir, que estamos ganando ciclos por no stolear el micro en caso de fallas en la predicción de salto, pero accedemos a la memoria sin hacer nada en caso de que el if falle. A la larga, la eficiencia debido a las fallas por mala predicción de salto es menor que la eficiencia debido al acceso a memoria sin hacer nada. 
(Esto es lo que me parece a mi, puede que no, que sea lo contrario. De todos modos depende mucho del código. Por ejemplo en nuestro código, habrá muchas veces en las que accederemos a memoria sin hacer nada, esto puede tener un impacto bastante significativo comparado con una mala predicción de salto,aunque analizando mejor, accedemos la misma cantidad de veces a memoria sin hacer nada que la cantidad de fallas del predictor de saltos) -->

![Dcache Hits](<stats/stats-ej3-img/Dcache Hits.png>)
![Dcache ReadReq Hits](<stats/stats-ej3-img/Dcache ReadReq Hits.png>)
![Ciclos de CPU en Stall](<stats/stats-ej3-img/Ciclos de CPU en Stall.png>)