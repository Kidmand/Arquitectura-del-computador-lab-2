.data
    N:       .dword 4096            // Number of elements in the vectors
    Alpha:   .dword 2               // scalar value

// ========================================================
// // Version de testeo con valores iniciales
// // - Incializamos X e Y con valores 5 flotates
     X: .float 1.0, 2.0, 3.0, 4.0, 5.0
     Y: .float 2.0, 3.0, 4.0, 5.0, 9.0   
 .bss                                                        
     Z: .zero  32768                     // Vector Y(4096)*8
// ========================================================

// ========================================================
// Version final sin valores iniciales
//.bss
//    X: .zero  32768                 // vector X(4096)*8
//    Y: .zero  32768                 // Vector Y(4096)*8  
//    Z: .zero  32768                 // Vector Y(4096)*8
// ========================================================

.text
//  =================== INIT: ========================
//          (esto lo pasaron los profes)    
    MRS X9, CPACR_EL1               // Read EL1 Architectural Feature Access Control Register
    MOVZ X10, 0x0030, lsl #16       // Set BITs 20 and 21
    ORR X9, X9, X10
    MSR CPACR_EL1, X9               // Write EL1 Architectural Feature Access Control Register

// =================== CONFIG: ========================

    ldr     x0, N       // Number of elements in the vectors
    ldr     x10, =Alpha // dir scalar value
    ldr     x2, =X      // dir vector X
    ldr     x3, =Y      // dir vector Y
    ldr     x4, =Z      // dir vector Z

// =================== MAIN: ========================

    /* CODIGO de DAXPY:
    const int N;
    double X[N], Y[N], Z[N], alpha;
    for (int i = 0; i < N; ++i)
    {
        Z[i] = alpha * X[i] + Y[i];
    }
    */
	// FIXME: no anda si N<=0
	ldr X5, [x10]    // D0 = alpha
	scvtf D0, x5     // pasamos alpha a flotante
	ADD X5, XZR, XZR // indice*8
	SUB x0, x0, #1   //
loop:
	ldr D1, [X2, X5] // D1 = X[i]
	ldr D2, [X3, X5] // D2 = Y[i]
	FMUL D3, D1, D0  // D3 = X[i] * alpha
	FADD D4, D3, D2  // D4 = (X[i] * alpha) + Y[i]
	str D4, [X4, X5] // Z[i] = (X[i] * alpha) + Y[i]
	ADD X5, X5, #8
	SUB x0, x0, #1
	CBNZ x0, loop
	
// ================= END-MAIN: ======================

infloop: B infloop
