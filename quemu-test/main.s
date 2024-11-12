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
    for (int i = 0; i < N; ++i)
    {
        Z[i] = alpha * X[i] + Y[i];
    }
    */

    // Como alpha es un escalar, lo cargamos
    // en un registro de punto flotante:
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

// ================= END-MAIN: ======================

infloop: B infloop