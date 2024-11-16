#include <stdio.h>
#define N 64
#define T_AMB 25
#define FC_X 0
#define FC_Y 0
#define FC_TEMP 100
#define N_ITER 10

int main()
{
    float sum, x[N * N], x_tmp[N * N];

    // Esta parte inicializa la matriz, solo es necesaria para verificar el código
    for (int i = 0; i < N * N; ++i)
    {
        x[i] = T_AMB;
    }
    x[FC_X * N + FC_Y] = FC_TEMP;

    for (int k = 0; k < N_ITER; ++k)
    {
        for (int i = 0; i < N; ++i)
        {
            for (int j = 0; j < N; ++j)
            {
                if ((i * N + j) != (FC_X * N + FC_Y))
                { // Si es distinto de la fuente de calor.
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

                    x_tmp[i * N + j] = sum / 4; // Calcular el promedio de las temperaturas.
                }
            }
        }

        // Carga los valores del arreglo temporal (x_tmp) al arreglo no temporal.
        for (int i = 0; i < N * N; ++i)
            if (i != (FC_X * N + FC_Y))
                x[i] = x_tmp[i];
    }

    for (int i = 0; i < N * N / 2; i += 2)
    {
        printf("%f %f \n", x[i], x[i + 1]);
    }
}

/*
Para copilar usar:
    gcc simFisica.c -o simFisica
Para ejecutar:
    ./simFisica > salida.txt
*/