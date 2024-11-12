# Arquitectura de Computadoras - 2024

## Informe Lab2:  Análisis de microarquitecturas

## Integrantes

- Alumno
- Alumno
- Alumno

## Ejercicio 1

Codigo:

```asm
    ldr X5, [x10]    // D0 = alpha
    scvtf D0, x5     // pasamos alpha a flotante
    ADD X5, XZR, XZR // indice*8
    SUB x0, x0, #1
loop:
    ldr D1, [X2, X5] // D1 = X[i]
    ldr D2, [X3, X5] // D2 = Y[i]
    FMUL D3, D1, D0  // D3 = X[i] * alpha
    FADD D4, D3, D2  // D4 = (  [i] * alpha) + Y[i]
    str D4, [X4, X5] // Z[i] = (    [i] * alpha) + Y[i]
    ADD X5, X5, #8
    SUB x0, x0, #1
    CBNZ x0, loop
```

Tenemos:

- Las estadisticas no cambian segun el tamano de cache
