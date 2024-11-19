.data
    N:       .dword 1024            // Número de elementos en los vectores
	Seed:    .dword 1234            // Semilla inicial para el generador LCG
    Mask:    .dword 0xFFFF          // Máscara de para los numeros aleatorios

.bss 
    Array:   .zero  8192            // Vector de 1024 elementos, cada uno de 8 bytes (1024 * 8 = 8192 bytes)

.text
//=================== INIT: =========================\\
    MRS X9, CPACR_EL1               // Read EL1 Architectural Feature Access Control Register
    MOVZ X10, 0x0030, lsl #16       // Set BITs 20 and 21
    ORR X9, X9, X10
    MSR CPACR_EL1, X9               // Write EL1 Architectural Feature Access Control Register

//=================== CONFIG: ========================\\

    ldr     X0, N                   // Cargar el número de elementos (N)
    ldr     X10, =Array             // Cargar la dirección del arreglo en X10
    ldr     X2, Seed                // Cargar la semilla inicial
    MOV     X3, #16645              // Multiplicador (a) para LCG
    MOV     X4, #10139              // Incremento (c) para LCG
    MOV     X5, #100                // Módulo (m), rango 0-99
    MOV     X6, #0                  // Índice inicial del arreglo
    ldr     X8, Mask               // Máscara para los números aleatorios

// ==================== Inicialización Aleatoria ====================\\
init_loop:
    CMP     X6, X0                  // Comparar el índice con el tamaño del arreglo
    B.GE    init_done               // Si el índice >= N, salir

        // Generar el siguiente número aleatorio
        MUL     X2, X2, X3              // current *= a
        ADD     X2, X2, X4              // current += c
        AND     X7, X2, X8              // aplicar máscara

        // Almacenar el valor aleatorio en el arreglo
        STR     X7, [X10, X6, LSL #3]   // Guardar el valor aleatorio en la posición arr[i]

        // Incrementar el índice
        ADD     X6, X6, #1
        B       init_loop

init_done:

//================ CÓDIGO A TRADUCIR: =================\\

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

MOV     X1, #0          // X1 = i
MOV     X2, #0          // X2 = j
SUB     X3, X0, #1      // X3 = (N - 1)

loop_i: 
    CMP     X1, X3
    B.GE    loop_i_end
        MOV     X2, #0      // j = 0
        SUB     X4, X3, X1  // X4 = N - i - 1 (límite para j)

        loop_j: 
            CMP     X2, X4
            B.GE    loop_j_end
                LDR     X5, [X10, X2, LSL #3]   // arr[j]
                ADD     X6, X2, #1
                LDR     X7, [X10, X6, LSL #3]   // arr[j + 1]

                CMP     X5, X7
                B.LE    fail_if                 // Si arr[j] <= arr[j + 1], saltar intercambio

                MOV     X8, X5
                STR     X7, [X10, X2, LSL #3]   // arr[j] = arr[j + 1]
                STR     X8, [X10, X6, LSL #3]   // arr[j + 1] = arr[j]

            fail_if:
                ADD     X2, X2, #1              // j++
                B       loop_j

        loop_j_end:
            ADD     X1, X1, #1                  // i++
            B       loop_i

loop_i_end:

//================= END-MAIN: ======================\\

infloop: B infloop
