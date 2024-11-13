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
