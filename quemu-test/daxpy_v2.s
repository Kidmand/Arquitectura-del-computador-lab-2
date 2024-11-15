.data
    N:       .dword 10      // Number of elements in the vectors
    Alpha:   .dword 2       // scalar value

// ========================================================
// Version con valores iniciales
    X:      .dword 0x3FF0000000000000, 0x4000000000000000, 0x4008000000000000, 0x4010000000000000, 0x4014000000000000, 0x3FF0000000000000, 0x4000000000000000, 0x4008000000000000, 0x4010000000000000, 0x4014000000000000
    Y:      .dword 0x3FF0000000000000, 0x4000000000000000, 0x4008000000000000, 0x4010000000000000, 0x4014000000000000, 0x3FF0000000000000, 0x4000000000000000, 0x4008000000000000, 0x4010000000000000, 0x4014000000000000         
    Z:      .dword 0x3FF0000000000000, 0x4000000000000000, 0x4008000000000000, 0x4010000000000000, 0x4014000000000000, 0x3FF0000000000000, 0x4000000000000000, 0x4008000000000000, 0x4010000000000000, 0x4014000000000000 
// ========================================================


.text
//  =================== INIT: ========================
//          (esto lo pasaron los profes)    
    MRS X9, CPACR_EL1               // Read EL1 Architectural Feature Access Control Register
    MOVZ X10, 0x0030, lsl #16       // Set BITs 20 and 21
    ORR X9, X9, X10
    MSR CPACR_EL1, X9               // Write EL1 Architectural Feature Access Control Register

// =================== CONFIG: ========================

    ldr     x0, N
    ldr     x10, =Alpha
    ldr     x2, =X
    ldr     x3, =Y
    ldr     x4, =Z

// =================== MAIN: ========================

    /* CODIGO de DAXPY:
    const int N;
    double X[N], Y[N], Z[N], alpha;
    // Pre: N es par y mayor a 2
    for (int i = 0; i < N/2; i+=2)
    {
        Z[i] = alpha * X[i] + Y[i];
        Z[i+1] = alpha * X[i+1] + Y[i+1];
    }
    */

    // Como alpha es un escalar, lo cargamos
    // en un registro de punto flotante:
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

// ================= END-MAIN: ======================

infloop: B infloop
