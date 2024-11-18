#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 1000

int main() {
    int arr[N];

    srand(time(NULL));
    for (int i = 0; i < N; i++) {
        arr[i] = rand() % 1000;
    }

    for (int i = 0; i < N - 1; i++) {
        for (int j = 0; j < N - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }

    printf("Arreglo ordenado:\n");
    for (int i = 0; i < N; i++) {
        printf("%d\n", arr[i]);
    }

    return 0;
}

// Para copilar usar:
//     gcc bubleSort.c -o bubleSort
// Para ejecutar:
//     ./bubleSort > bubleSort.txt
