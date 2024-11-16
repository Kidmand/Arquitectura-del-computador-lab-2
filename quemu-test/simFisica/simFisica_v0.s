.data
	N:       .dword 64	
	t_amb:   .dword 25   
	n_iter:  .dword 10    
    fc_x:    .dword 0
	fc_y:    .dword 0
    fc_temp: .dword 100

.bss 
	x: .zero  32768        
	x_temp: .zero  32768    

.text
//  =================== INIT: ========================
//          (esto lo pasaron los profes)    
    MRS X9, CPACR_EL1               // Read EL1 Architectural Feature Access Control Register
    MOVZ X10, 0x0030, lsl #16       // Set BITs 20 and 21
    ORR X9, X9, X10
    MSR CPACR_EL1, X9               // Write EL1 Architectural Feature Access Control Register

//  =================== CONFIG: ========================
    ldr     x0, N
    ldr     x1, =x 
    ldr     x2, =x_temp
    ldr     x3, n_iter
	ldr     x4, t_amb
    ldr     x5, fc_x
    ldr     x6, fc_y
    ldr     x7, fc_temp

//  ================ CÓDIGO A TRDUCIR: =================
/* 
const int n_iter, fc_x, fc_y;
float fc_temp,sum, x[N*N], x_tmp[N*N], t_amb;

// Esta parte inicializa la matriz, solo es necesaria para verificar el código
for (int i = 0; i < N*N; ++i) {
        x[i] = t_amb;
}
x[fc_x*N+fc_y] = fc_temp;

for(int k = 0; k < n_iter; ++k) {
    for(int i = 0; i < N; ++i) {
        for(int j = 0; j < N; ++j) {
            if((i*N + j) != (fc_x*N + fc_y)){       // Si es distinto de la fuente de calor. 
                sum = 0;
                if(i + 1 < N)                       // Casilla abajo
                    sum = sum + x[(i+1)*N + j];
                else
                    sum = sum + t_amb;

                if(i - 1 >= 0)                      // Casilla arriba
                    sum = sum + x[(i-1)*N + j];
                else
                    sum = sum + t_amb;

                if(j + 1 < N)                       // Casilla derecha
                    sum = sum + x[i*N + j+1];
                else
                    sum = sum + t_amb;

                if(j - 1 >= 0)                      // Casilla izquierda.
                    sum = sum + x[i*N + j-1];
                else
                    sum = sum + t_amb;

                x_tmp[i*N + j] = sum / 4;           // Calcular el promedio de las temperaturas.
            }
        }
    }

    //Carga los valores del arreglo temporal (x_tmp) al arreglo no temporal.
    for (int i = 0; i < N*N; ++i) 
        if(i != (fc_x*N + fc_y))
            x[i] = x_tmp[i];
}
*/
// =================== MAIN: ========================

scvtf D0, x4    
MOV X8, #0              // X8 = i Condición para salto
MOV X9, #0              // X9 = i*8 Que es la posición de cada elemento. 
MUL X10, X0, X0         // X10 = N*N

loop_init_t_amb: 
    CMP X8, X10
    B.GE loop_init_t_amb_end    // if i >= N, end
    STR D0, [X1, x9]            // x[i] = t_amb
    ADD X8, X8, #1              // i(X8) = i + 1
    ADD X9, X9, #8
    B loop_init_t_amb
loop_init_t_amb_end: 

scvtf D1, x7  
MADD X11, X5, X0, X6        // X11 = fc_x(X5) * N(X0) + fc_y(X6)
STR D1, [X1, X11]           // x[fc_x*N+fc_y] = fc_temp(D1);

MOV X8, #0                  // X8 = k
MOV X9, #0                  // X9 = i
MOV X10, #0                 // X10 = j
MOV X25, #0                 // X25 = h
MOV X11, X3                 // X11 = (n_iter = 10)
MOV X12, X0                 // X12 = (N = 64)
MUL X26, X0, X0             // X26 = N*N
MADD X14, X5, x0, X6        // X14 = fc_x(X5) * N(X0) + fc_y(X6) (ie, el punto de calor)
FMOV D8, #4.0               // D8  = 4

loop_k: 
    CMP X8, X11
    B.GE loop_k_end            // if k >= n_iter, go end
        MOV X9, #0                 // i = 0
        loop_i:
            CMP X9, X12
            B.GE loop_i_end           // if i >= N, go end
                MOV X10, #0               // j = 0
                loop_j:
                    CMP X10, X12
                    B.GE loop_j_end             // if j >= N, go end
                        MADD X13, X9, X12, X10      // X13 = i(X9) * N(X12) + j(X10)  
                        CMP X13, X14
                        B.EQ loop_j_end_if          // if (i*N + j) == (fc_x*N + fc_y), end
                            MOVI D2, #0                 // SUM = 0.0

                            // ---------- Casilla abajo ---------
                            ADD X16, X9, #1
                            CMP X16, X12                
                            B.GE casilla_abajo          // if i + 1 < N, go end
                                MADD X17, X16, X12, X10         // X17 = (i+1)(X16) * N(X12) + j(X10)
                                LSL X17, X17, #3
                                LDR D3, [X1, X17]               // D3 = x[(i+1)*N + j]
                                FADD D2, D2, D3                 // SUM = SUM + x[(i+1)*N + j]
                                B casilla_abajo_end
                            casilla_abajo:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_abajo_end:
                            // -----------------------------------

                            // ---------- Casilla arriba ---------
                            SUB X18, X9, #1
                            CMP X18, XZR                
                            B.LT casilla_arriba         // if i - 1 >= 0, go end
                                MADD X19, X18, X12, X10         // X19 = (i-1)(X18) * N(X12) + j(X10)
                                LSL X19, X19, #3
                                LDR D4, [X1, X19]               // D4 = x[(i-1)*N + j]
                                FADD D2, D2, D4                 // SUM = SUM + x[(i-1)*N + j]
                                B casilla_arriba_end
                            casilla_arriba:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_arriba_end:
                            // -----------------------------------

                            // --------- Casilla derecha ---------
                            ADD X20, X10, #1
                            CMP X20, X12
                            B.GE casilla_derecha        // if j + 1 < N, go end
                                MADD X21, X9, X12, X20          // X21 = (i)(X16) * N(X12) + (j+1)(X10)
                                LSL X21, X21, #3
                                LDR D5, [X1, X21]               // D5 = x[i*N + j+1]
                                FADD D2, D2, D5                 // SUM = SUM + x[i*N + j+1]
                                B casilla_derecha_end
                            casilla_derecha:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_derecha_end:
                            // ----------------------------------

                            // -------- Casilla izquierda -------
                            SUB X22, X10, #1
                            CMP X22, XZR
                            B.LT casilla_izquierda      // if j - 1 >= 0, go end
                                MADD X23, X9, X12, X22         // X23 = (i)(X16) * N(X12) + (j-1)(X10)
                                LSL X23, X23, #3
                                LDR D6, [X1, X23]              // D6 = x[i*N + j-1]
                                FADD D2, D2, D6                // SUM = SUM + x[i*N + j-1]
                                B casilla_izquierda_end
                            casilla_izquierda:
                                FADD D2, D2, D0                // SUM = SUM + t_amb
                            casilla_izquierda_end:
                            // ----------------------------------

                            // -------- Guardar en x_tmp --------
                            FDIV D2, D2, D8             // SUM = SUM / 4                 
                            MADD X24, X9, X12, X10      // X24 = i(X9) * N(12) + j(10)
                            LSL X24, X24, #3        
                            STR D2, [X2, X24]           // x_tmp[i*N + j] = SUM
                            // ----------------------------------

                    loop_j_end_if:
                        ADD  X10, X10, #1           // j(X10) = j + 1
                        B loop_j

                loop_j_end:
                    ADD X9, X9, #1                  // i(X9) = i + 1
                    B loop_i

        loop_i_end:  

            // -------- Cargar valores de x_tmp a x --------
            MOV X25, #0       // h = 0
            MOV X28, #0
            loop_h:
                CMP X25, X26
                B.GE loop_h_end     // if h >= N*N, go end
                    CMP X25, X14
                    B.EQ loop_h_end_if      // if h == (fc_x*N + fc_y), go end
                        LDR D7, [X2, X28]       // D7 = x_tmp[h]
                        STR D7, [X1, X28]       // x[h] = x_tmp[h]
                    loop_h_end_if:
                    ADD X25, X25, #1        // h = h + 1
                    ADD X28, X28, #8        // x28 = x28 + 8
                    B loop_h

            loop_h_end:
            // ----------------------------------------------

            ADD X8, X8, #1                      // k(X8) = k + 1
            b loop_k
loop_k_end:

// ================= END-MAIN: ======================

infloop: B infloop
