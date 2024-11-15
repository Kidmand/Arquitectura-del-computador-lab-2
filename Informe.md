# Arquitectura de Computadoras - 2024

## Informe Lab2:  Análisis de microarquitecturas

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

Tenemos:

- Gráficos Dcahe Hits y Dcache remplacements inversamente proporcionales.(+remplazos --> -hits)
- Mas hits totales que de lectura porque tenemos de escritura de Z.
- Con 2 vias no se notan los hits de escritura ¿ya que siempre se reemplazan?.
- Gráficos de cantidad de stalls y numero de ciclos proporcionales. (+stall -->  +cilos)
- Hacer gráfico de numero de ciclos - cantidad de stalls (decrece)
- El tamaño de cache no influye ya que no se vuelven a leer los datos de los arreglos.
- Un array entero tiene 32KB = 4096 * 8B
- Una linea de cache tiene 64B

Como se vera en cada gráfico, las estadísticas no cambian según el tamaño de la cache.
En nuestro programa, accedemos (lectura/escritura) secuencialmente a los datos de los arreglos solo una vez cada uno. Por lo tanto no volveremos a necesitar un bloque al que ya hemos accedido entero, entonces, no hace falta que persistan en cache ya que no lo volveremos a necesitar. Por lo tanto aumentar el tamaño de cache no surtirá nigun efecto en nuestras estadísticas. Hacerlo nos permitiría guardar mas bloques, pero no nos hace falta ya que  nosotros solo necesitamos guardar uno por arreglo.

Aunque el tamaño de cache de datos no nos afecta, la cantidad de vias si. Así como en el siguiente caso de análisis:

Al considerar la cantidad de ciclos/clocks del programa, podemos ver que al variar la cantidad de vias tenemos diferentes resultados.

Antes notar algo que sucede por el tamaño del arreglo en relación al tamaño de la cache. El arreglo tiene 4096 elementos de 8 bytes, es decir cada uno ocupa 32kB y por como están inicializados los arreglos en memoria ram, estos se encuentran uno seguido al otro, es decir esta primero el arreglo X, luego el arreglo Y, y finalmente el Z. Como los tamaños de cache son multiplos de 32kB (son de 8kb, 16kB, y 32kB), analisando el caso de una sola via, tenemos que un elemento del arreglo X y un elmento del arreglo Y caen justamente en la misma linea, por lo explicado anteriormente (ie como esta organizada la memoria). Lo mismo pasa con el arrego Z, entonces se pisan siempre las lineas de cache. Veamos esto en el gráfico:

![Ciclos Simulados](<stats/stats-ej1-img/Ciclos Simulados.png>)

Notar, la mejor al tener 2 vias. Gracias a ellas tenemos que las lineas no se pisan tanto, es decir, como la cache tiene lineas de 64 bytes, (ie 8 palabras de 8 bytes) tenemos que se cargan en un set elementos del X y elementos de Y, estas se leen todas y dan hit por ello disminuye la cantidad de stall:

![Ciclos de CPU en Stall](<stats/stats-ej1-img/Ciclos de CPU en Stall.png>)

Y notar que justamente la cantidad de stalls es inversamente proporcional a la cantidad de ciclos totales de la simulación.

FIXME: Notar que hay un comportamiento raro con la cache de 4 vias, debería ser igual al comportamiento del de 2 vias e igual con el de 8 vias.

Notar que todo lo anterior se relaciona con la cantidad de hits, en el caso del de 1 via podemos ver en los gráficos que tenemos pocos.

![Dcache Hits](<stats/stats-ej1-img/Dcache Hits.png>)
![Dcache ReadReq Hits](<stats/stats-ej1-img/Dcache ReadReq Hits.png>)

Específicamente tenemos valores que entran en el rango de error de la simulación, pero deberían ser 0, ya que siempre se remplazan las lineas. Luego para el caso de 2 vias, vemos como mejora la cantidad de hits porque justamente no tenemos los reemplazos de linea.
TODO: COMPLETAR PARA CASO DE 4 Y 8 VIAS ...
