.data
	N:       .dword 64	
	t_amb:   .dword 25   
	n_iter:  .dword 10    
    fc_x:    .dword 0
	fc_y:    .dword 0
    fc_temp: .dword 100

.bss 
	x: .zero  3072        
	x_temp: .zero  3072    

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

//  =================== CÓDIGO A TRDUCIR: ========================
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

MOV X8, #0              // X8 = i Condición para salto
MOV X9, X1              // X9 = i*8 Que es la posición de cada elemento. 
MUL X10, X0, X0         // N*N

loop_init_t_amb: 
    CMP X9, X10
    B.GE loop_init_t_amb_end
    STR X4, [X9]
    ADD X8, X8, #1
    ADD X9, X9, #8
    B loop_init_t_amb
loop_init_t_amb_end: 

MADD X11, X5, X0, X6    // X11 = fc_x(X5) * N(X0) + fc_y(X6)
STR X7, [X11]           // x[fc_x*N+fc_y] = fc_temp(X7);

MOV X8, #0          // X8 = k
MOV X9, #0          // X9 = i
MOV X10, #0         // X10 = j
MOV X25, #0         // X25 = h
MOV X11, X3         // X11 = (n_iter = 10)
MOV X12, X0         // X12 = (N = 64)
MOV X15, #0         // X15 = (SUM = 0)
MUL X26, X0, X0     // X26 = N*N

loop_k: 
    CMP X8, X11
    B.GE loop_k_end
    MOV X9, #0
    loop_i:
        CMP X9, X12
        B.GE loop_i_end
        MOV X10, #0
        loop_j:
            CMP X10, X12
            B.GE loop_j_end
            MADD X13, X9, X12, X11      // X13 = i(X9) * N(X12) + j(X11)
            MADD X14, X5, X12, X6       // X14 = fc_x(X5) * N(12) + fc_y(X6)
            CMP X13, X14
            B.EQ loop_j_end_if
                MOV X15, #0

                ADD X16, X9, #1
                CMP X16, X12
                B.GE casilla_abajo
                    MADD X17, X16, X12, X10         // X17 = (i+1)(X16) * N(X12) + j(X10)
                    LDUR X17, [X17] 
                    ADD X15, X15, X17
                    B casilla_abajo_end
                casilla_abajo:
                    ADD X15, X15, X4
                casilla_abajo_end:

                SUB X18, X9, #1
                CMP X18, XZR
                B.LT casilla_arriba
                    MADD X19, X18, X12, X10         // X19 = (i-1)(X16) * N(X12) + j(X10)
                    LDUR X19, [X19] 
                    ADD X15, X15, X19
                    B casilla_arriba_end
                casilla_arriba:
                    ADD X15, X15, X4
                casilla_arriba_end:

                ADD X20, X10, #1
                CMP X20, X12
                B.GE casilla_derecha
                    MADD X21, X9, X12, X20         // X21 = (i)(X16) * N(X12) + (j+1)(X10)
                    LDUR X21, [X21] 
                    ADD X15, X15, X21
                    B casilla_derecha_end
                casilla_derecha:
                    ADD X15, X15, X4
                casilla_derecha_end:

                SUB X22, X10, #1
                CMP X22, XZR
                B.LT casilla_izquierda
                    MADD X23, X9, X12, X22         // X21 = (i)(X16) * N(X12) + (j-1)(X10)
                    LDUR X23, [X23] 
                    ADD X15, X15, X23
                    B casilla_izquierda_end
                casilla_izquierda:
                    ADD X15, X15, X4
                casilla_izquierda_end:

                LSR X15, X15, #2
                MADD X24, X9, X12, X10              // X24 = i(X9) * N(12) + j(10)
                STR X15, [X2, X24]

            loop_j_end_if:
                ADD  X10, X10, #1           // j(X10) = j + 1
                B loop_j

        loop_j_end:
            ADD X9, X9, #1
            B loop_i

    loop_i_end:  

        MOV X25, #0
        loop_h:
            CMP X25, X26
            B.GE loop_h_end
            MADD X27, X5, X12, X6
            CMP X25, X27
            B.NE loop_h_end_if
            LDR X28, [X2, X25]
            STR X28, [X1, X25]
            loop_h_end_if:
            ADD X25, X25, #1
            B loop_h

        loop_h_end:

        ADD X8, X8, #1
        b loop_k
loop_k_end:

// ================= END-MAIN: ======================

infloop: B infloop
