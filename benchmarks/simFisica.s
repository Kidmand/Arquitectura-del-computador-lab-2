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

	.arch armv8-a
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB6:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	mov	x1, 0
	mov	x0, 0
	bl	m5_dump_stats

	ldr     x0, N
    ldr     x1, =x 
    ldr     x2, =x_temp
    ldr     x3, n_iter
	ldr     x4, t_amb
    ldr     x5, fc_x
    ldr     x6, fc_y
    ldr     x7, fc_temp

//---------------------- CODE HERE ------------------------------------

scvtf D0, x4    
MOV X8, #0                      // X8 = i Condición para salto
MUL X10, X0, X0                 // X10 = N*N

loop_init_t_amb: 
    CMP X8, X10
    B.GE loop_init_t_amb_end    // if i >= N, end
    STR D0, [X1, X8, LSL #3]    // x[i] = t_amb
    ADD X8, X8, #1              // i(X8) = i + 1
    B loop_init_t_amb
loop_init_t_amb_end: 

scvtf D1, x7  
MADD X11, X5, X0, X6            // X11 = fc_x(X5) * N(X0) + fc_y(X6)
STR D1, [X1, X11, LSL #3]       // x[fc_x*N+fc_y] = fc_temp(D1);

MOV X8, #0                      // X8 = k
MOV X9, #0                      // X9 = i
MOV X10, #0                     // X10 = j
MOV X25, #0                     // X25 = h
MOV X11, X3                     // X11 = (n_iter = 10)
MOV X12, X0                     // X12 = (N = 64)
MUL X26, X0, X0                 // X26 = N*N
MADD X14, X5, x0, X6            // X14 = fc_x(X5) * N(X0) + fc_y(X6) (ie, el punto de calor)
FMOV D8, #4.0                   // D8  = 4

loop_k: 
    CMP X8, X11
    B.GE loop_k_end                                             // if k >= n_iter, go end
        MOV X9, #0                                              // i = 0
        loop_i:
            CMP X9, X12
            B.GE loop_i_end                                     // if i >= N, go end
                MOV X10, #0                                     // j = 0
                loop_j:
                    CMP X10, X12
                    B.GE loop_j_end                             // if j >= N, go end
                        MADD X13, X9, X12, X10                  // X13 = i(X9) * N(X12) + j(X10)  
                        CMP X13, X14
                        B.EQ loop_j_end_if                      // if (i*N + j) == (fc_x*N + fc_y), end
                            MOVI D2, #0                         // SUM = 0.0


                            //---------- Casilla abajo ---------\\
                            ADD X16, X9, #1
                            CMP X16, X12                
                            B.GE casilla_abajo                  // if i + 1 < N, go end
                                MADD X17, X16, X12, X10         // X17 = (i+1)(X16) * N(X12) + j(X10)
                                LDR D3, [X1, X17, LSL #3]       // D3 = x[(i+1)*N + j]
                                FADD D2, D2, D3                 // SUM = SUM + x[(i+1)*N + j]
                                B casilla_abajo_end
                            casilla_abajo:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_abajo_end:
                            //-----------------------------------\\


                            //---------- Casilla arriba ---------\\
                            SUB X18, X9, #1
                            CMP X18, XZR                
                            B.LT casilla_arriba                 // if i - 1 >= 0, go end
                                MADD X19, X18, X12, X10         // X19 = (i-1)(X18) * N(X12) + j(X10)
                                LDR D4, [X1, X19, LSL #3]       // D4 = x[(i-1)*N + j]
                                FADD D2, D2, D4                 // SUM = SUM + x[(i-1)*N + j]
                                B casilla_arriba_end
                            casilla_arriba:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_arriba_end:
                            //-----------------------------------\\


                            //--------- Casilla derecha ---------\\
                            ADD X20, X10, #1
                            CMP X20, X12
                            B.GE casilla_derecha                // if j + 1 < N, go end
                                MADD X21, X9, X12, X20          // X21 = (i)(X16) * N(X12) + (j+1)(X10)
                                LDR D5, [X1, X21, LSL #3]       // D5 = x[i*N + j+1]
                                FADD D2, D2, D5                 // SUM = SUM + x[i*N + j+1]
                                B casilla_derecha_end
                            casilla_derecha:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_derecha_end:
                            //----------------------------------\\


                            //-------- Casilla izquierda -------\\
                            SUB X22, X10, #1
                            CMP X22, XZR
                            B.LT casilla_izquierda              // if j - 1 >= 0, go end
                                MADD X23, X9, X12, X22          // X23 = (i)(X16) * N(X12) + (j-1)(X10)
                                LDR D6, [X1, X23, LSL #3]       // D6 = x[i*N + j-1]
                                FADD D2, D2, D6                 // SUM = SUM + x[i*N + j-1]
                                B casilla_izquierda_end
                            casilla_izquierda:
                                FADD D2, D2, D0                 // SUM = SUM + t_amb
                            casilla_izquierda_end:
                            //----------------------------------\\


                            //-------- Guardar en x_tmp --------\\
                            FDIV D2, D2, D8                     // SUM = SUM / 4                 
                            MADD X24, X9, X12, X10              // X24 = i(X9) * N(12) + j(10)
                            STR D2, [X2, X24, LSL #3]           // x_tmp[i*N + j] = SUM
                            //----------------------------------\\

                    loop_j_end_if:
                        ADD  X10, X10, #1                       // j(X10) = j + 1
                        B loop_j

                loop_j_end:
                    ADD X9, X9, #1                              // i(X9) = i + 1
                    B loop_i

        loop_i_end:  

            //-------- Cargar valores de x_tmp a x --------\\
            MOV X25, #0                                         // h = 0
            loop_h:
                CMP X25, X26
                B.GE loop_h_end                                 // if h >= N*N, go end
                    CMP X25, X14
                    B.EQ loop_h_end_if                          // if h == (fc_x*N + fc_y), go end
                        LDR D7, [X2, X25, LSL #3]               // D7 = x_tmp[h]
                        STR D7, [X1, X25, LSL #3]               // x[h] = x_tmp[h]
                    loop_h_end_if:
                    ADD X25, X25, #1                            // h = h + 1
                    B loop_h

            loop_h_end:
            //----------------------------------------------\\

            ADD X8, X8, #1                                      // k(X8) = k + 1
            b loop_k
loop_k_end:

//---------------------- END CODE -------------------------------------

	mov 	x0, 0
	mov 	x1, 0
	bl	m5_dump_stats
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
