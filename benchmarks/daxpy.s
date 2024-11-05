	.data
	N:       .dword 4096	// Number of elements in the vectors
	Alpha:   .dword 2      // scalar value
	
	.bss 
	X: .zero  32768        // vector X(4096)*8
	Y: .zero  32768        // Vector Y(4096)*8
        Z: .zero  32768        // Vector Y(4096)*8

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
    	ldr     x10, =Alpha
    	ldr     x2, =X
    	ldr     x3, =Y
	ldr     x4, =Z

//---------------------- CODE HERE ------------------------------------

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
