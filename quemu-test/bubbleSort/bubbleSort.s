.text
    N:  .dword 1024	        // Number of elements in the vectors
	
.bss 
    Array:  .zero  8192     // vector X(1000)*8

.data
    Seed:         .dword 123456  // Semilla inicial para el generador LCG

.text
.global _start

_start:
//=================== INIT: ========================\\
    MRS X9, CPACR_EL1               // Read EL1 Architectural Feature Access Control Register
    MOVZ X10, 0x0030, lsl #16       // Set BITs 20 and 21
    ORR X9, X9, X10
    MSR CPACR_EL1, X9               // Write EL1 Architectural Feature Access Control Register

//=================== CONFIG: ========================\\

    ldr     X0, N
    ldr     x10, =Array 
    ldr X2, Seed                 // Semilla inicial
    MOV X3, #1664                // Multiplicador (a) para LCG
    MOV X4, #1013                // Incremento (c) para LCG
    MOV X5, #100                 // Módulo (m), rango 0-99
    MOV X6, #0                   // Índice inicial del arreglo


// ==================== Inicialización Aleatoria ====================\\
init_loop:
    CMP X6, X0                   // Comparar índice con tamaño del arreglo
    B.GE init_done               // Si índice >= N, salir

    // Generar el siguiente número aleatorio
    MUL X2, X2, X3               // current *= a
    ADD X2, X2, X4               // current += c
    UDIV X7, X2, X5              // next = current % m
    MADD X7, X7, X5, XZR         // Asegurarse de que el resultado esté dentro del rango

    // Almacenar en el arreglo
    STR X7, [X1, X6, LSL #3]     // Guardar el valor aleatorio en el arreglo

    // Incrementar índice
    ADD X6, X6, #1
    B init_loop

init_done:

//================ CÓDIGO A TRDUCIR: =================\\

/*
for (int i = 0; i < N - 1; i++) {
    for (int j = 0; j < N - i - 1; j++) {
        if (arr[j] > arr[j + 1]) {
            int temp = arr[j];
            arr[j] = arr[j + 1];
            arr[j + 1] = temp;
        }
    }
}*/

//=================== MAIN: ========================\\

MOV X1, #0          // X8 = i
MOV X2, #0          // X9 = j
SUB X3, X0, #1      // X3 = (N - 1)

loop_i: 
    CMP X1, X3
    B.GE loop_i_end
        MOV X2, #0                              // j = 0
        SUB X4, X3, X1                          // X4 = N - i - 1 (límite para j)

        loop_j: 
            CMP X2, X4
            B.GE loop_j_end
                LDR X5, [X10, X2, LSL #3]       // arr[j]
                ADD X6, X2, #1
                LDR x7, [X10, X6, LSL #3]       // arr[j+1]

                CMP X5, x7
                B.LE fail_if                    // Si arr[j] <= arr[j+1], saltar intercambio

                MOV X8, X5
                STR X7, [X10, X2, LSL #3]       // arr[j] = arr[j+1]
                STR X8, [X10, X6, LSL #3]       // arr[j+1] = arr[j]

            fail_if:
                ADD X2, X2, #1                  // j++
                B loop_j

        loop_j_end:
            ADD X1, X1, #1                      // i++
            B loop_i

loop_i_end:
    
//================= END-MAIN: ======================\\

infloop: B infloop
