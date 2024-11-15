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

                x_tmp[i*N + j] = sum / 4;       // Calcular el promedio de las temperaturas.
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
    STUR X4, [X9]
    ADD X8, X8, #1
    ADD X9, X9, #8
    B loop_init_t_amb
loop_init_t_amb_end: 

MADD X11, X5, X0, X6    // X11 = fc_x(X5) * N(X0) + fc_y(x6)
STUR X7, [X11]          // x[fc_x*N+fc_y] = fc_temp;


// ================= END-MAIN: ======================

infloop: B infloop
