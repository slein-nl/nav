	.file	"nav.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	compare_entries
	.type	compare_entries, @function
compare_entries:
.LFB27:
	.cfi_startproc
	mov	rsi, QWORD PTR [rsi]
	mov	rdi, QWORD PTR [rdi]
	jmp	strcmp@PLT
	.cfi_endproc
.LFE27:
	.size	compare_entries, .-compare_entries
	.p2align 4
	.globl	panic
	.type	panic, @function
panic:
.LFB25:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	rbx, rdi
	mov	rdi, QWORD PTR win[rip]
	call	delwin@PLT
	call	endwin@PLT
	mov	rdi, rbx
	call	puts@PLT
	mov	edi, 1
	call	exit@PLT
	.cfi_endproc
.LFE25:
	.size	panic, .-panic
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Ctrl + C pressed"
	.text
	.p2align 4
	.globl	sigint_handler
	.type	sigint_handler, @function
sigint_handler:
.LFB40:
	.cfi_startproc
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	lea	rdi, .LC0[rip]
	call	panic
	.cfi_endproc
.LFE40:
	.size	sigint_handler, .-sigint_handler
	.section	.rodata.str1.1
.LC1:
	.string	"realloc error"
	.text
	.p2align 4
	.type	extend_entry_array.part.0, @function
extend_entry_array.part.0:
.LFB42:
	.cfi_startproc
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	lea	rdi, .LC1[rip]
	call	panic
	.cfi_endproc
.LFE42:
	.size	extend_entry_array.part.0, .-extend_entry_array.part.0
	.set	extend_ptrs_array.part.0,extend_entry_array.part.0
	.set	extend_entry_array_pointers.part.0,extend_entry_array.part.0
	.section	.rodata.str1.1
.LC2:
	.string	"SHELL"
.LC4:
	.string	"memory allocation error"
	.text
	.p2align 4
	.globl	init
	.type	init, @function
init:
.LFB26:
	.cfi_startproc
	push	r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	lea	rdi, .LC2[rip]
	push	r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	push	r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	push	rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	push	rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	lea	rbx, current_path[rip]
	call	getenv@PLT
	mov	esi, 4096
	mov	rdi, rbx
	mov	QWORD PTR user_shell[rip], rax
	call	getcwd@PLT
	mov	rdi, rbx
	call	strlen@PLT
	movdqa	xmm0, XMMWORD PTR .LC3[rip]
	mov	edi, 512
	mov	DWORD PTR current_path_length[rip], eax
	movaps	XMMWORD PTR file_array[rip], xmm0
	call	malloc@PLT
	mov	edi, 512
	mov	r13, rax
	mov	QWORD PTR file_array[rip+24], rax
	call	malloc@PLT
	movdqa	xmm0, XMMWORD PTR .LC3[rip]
	mov	edi, 512
	mov	rbp, rax
	mov	QWORD PTR file_array[rip+16], rax
	movaps	XMMWORD PTR dir_array[rip], xmm0
	call	malloc@PLT
	mov	edi, 512
	mov	r14, rax
	mov	QWORD PTR dir_array[rip+24], rax
	call	malloc@PLT
	mov	edi, 512
	mov	QWORD PTR found_ptrs[rip+4], 0
	mov	r12, rax
	mov	QWORD PTR dir_array[rip+16], rax
	call	malloc@PLT
	mov	edi, 512
	mov	DWORD PTR found_ptrs[rip], 512
	mov	rbx, rax
	mov	QWORD PTR found_ptrs[rip+16], rax
	mov	QWORD PTR all_ptrs[rip+4], 0
	call	malloc@PLT
	test	r14, r14
	mov	DWORD PTR all_ptrs[rip], 512
	sete	dl
	test	r13, r13
	mov	QWORD PTR all_ptrs[rip+16], rax
	sete	cl
	or	edx, ecx
	test	r12, r12
	sete	cl
	or	edx, ecx
	test	rbp, rbp
	sete	cl
	or	edx, ecx
	test	rbx, rbx
	sete	cl
	or	dl, cl
	jne	.L12
	test	rax, rax
	je	.L12
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	pop	rbp
	.cfi_def_cfa_offset 32
	pop	r12
	.cfi_def_cfa_offset 24
	pop	r13
	.cfi_def_cfa_offset 16
	pop	r14
	.cfi_def_cfa_offset 8
	ret
.L12:
	.cfi_restore_state
	lea	rdi, .LC4[rip]
	call	panic
	.cfi_endproc
.LFE26:
	.size	init, .-init
	.p2align 4
	.globl	extend_entry_array
	.type	extend_entry_array, @function
extend_entry_array:
.LFB28:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	eax, DWORD PTR [rdi]
	mov	rbx, rdi
	mov	rdi, QWORD PTR 24[rdi]
	lea	esi, [rax+rax]
	movsx	rsi, esi
	call	realloc@PLT
	test	rax, rax
	je	.L15
	mov	rdi, QWORD PTR 24[rbx]
	mov	rcx, rax
	cmp	rdi, rax
	je	.L16
	mov	esi, DWORD PTR 12[rbx]
	test	esi, esi
	jle	.L17
	mov	rdx, QWORD PTR 16[rbx]
	mov	rax, QWORD PTR [rdx]
	sub	rax, rdi
	add	rax, rcx
	mov	QWORD PTR [rdx], rax
	cmp	esi, 1
	je	.L17
	lea	edi, -2[rsi]
	lea	rax, 8[rdx]
	cmp	edi, 1
	jbe	.L23
	mov	eax, esi
	lea	r8, 24[rbx]
	lea	rax, [rdx+rax*8]
	cmp	r8, rax
	jnb	.L27
	lea	rax, 8[rdx]
	lea	r8, 32[rbx]
	cmp	r8, rax
	jbe	.L27
.L23:
	lea	rsi, 16[rdx+rdi*8]
	.p2align 4,,10
	.p2align 3
.L21:
	mov	rdx, QWORD PTR [rax]
	add	rax, 8
	add	rdx, rcx
	sub	rdx, QWORD PTR 24[rbx]
	mov	QWORD PTR -8[rax], rdx
	cmp	rsi, rax
	jne	.L21
.L17:
	mov	QWORD PTR 24[rbx], rcx
.L16:
	sal	DWORD PTR [rbx]
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L27:
	.cfi_restore_state
	sub	esi, 1
	movq	xmm0, QWORD PTR 24[rbx]
	movq	xmm1, rcx
	mov	rax, rdx
	mov	edi, esi
	punpcklqdq	xmm1, xmm1
	shr	edi
	punpcklqdq	xmm0, xmm0
	sal	rdi, 4
	psubq	xmm1, xmm0
	add	rdi, rdx
	.p2align 4,,10
	.p2align 3
.L25:
	movdqu	xmm0, XMMWORD PTR 8[rax]
	add	rax, 16
	paddq	xmm0, xmm1
	movups	XMMWORD PTR -8[rax], xmm0
	cmp	rax, rdi
	jne	.L25
	mov	eax, esi
	or	eax, 1
	and	esi, 1
	je	.L17
	cdqe
	lea	rdx, [rdx+rax*8]
	mov	rax, QWORD PTR [rdx]
	add	rax, rcx
	sub	rax, QWORD PTR 24[rbx]
	mov	QWORD PTR [rdx], rax
	mov	QWORD PTR 24[rbx], rcx
	jmp	.L16
.L15:
	call	extend_entry_array.part.0
	.cfi_endproc
.LFE28:
	.size	extend_entry_array, .-extend_entry_array
	.p2align 4
	.globl	extend_entry_array_pointers
	.type	extend_entry_array_pointers, @function
extend_entry_array_pointers:
.LFB29:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	eax, DWORD PTR 4[rdi]
	mov	rbx, rdi
	mov	rdi, QWORD PTR 16[rdi]
	lea	esi, [rax+rax]
	movsx	rsi, esi
	call	realloc@PLT
	test	rax, rax
	je	.L42
	mov	QWORD PTR 16[rbx], rax
	sal	DWORD PTR 4[rbx]
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L42:
	.cfi_restore_state
	call	extend_entry_array_pointers.part.0
	.cfi_endproc
.LFE29:
	.size	extend_entry_array_pointers, .-extend_entry_array_pointers
	.p2align 4
	.globl	extend_ptrs_array
	.type	extend_ptrs_array, @function
extend_ptrs_array:
.LFB30:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	eax, DWORD PTR [rdi]
	mov	rbx, rdi
	mov	rdi, QWORD PTR 16[rdi]
	lea	esi, [rax+rax]
	movsx	rsi, esi
	call	realloc@PLT
	test	rax, rax
	je	.L46
	mov	QWORD PTR 16[rbx], rax
	sal	DWORD PTR [rbx]
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L46:
	.cfi_restore_state
	call	extend_ptrs_array.part.0
	.cfi_endproc
.LFE30:
	.size	extend_ptrs_array, .-extend_ptrs_array
	.p2align 4
	.globl	add_found_ptr
	.type	add_found_ptr, @function
add_found_ptr:
.LFB31:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rdi
	push	rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	sub	rsp, 8
	.cfi_def_cfa_offset 32
	mov	ebx, DWORD PTR found_ptrs[rip+8]
	add	ebx, DWORD PTR found_ptrs[rip+4]
	sal	ebx, 3
	movsx	rdx, DWORD PTR found_ptrs[rip]
	mov	rdi, QWORD PTR found_ptrs[rip+16]
	movsx	rbx, ebx
	lea	rax, 8[rbx]
	cmp	rdx, rax
	jb	.L53
	mov	QWORD PTR [rdi+rbx], rbp
	add	rsp, 8
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	pop	rbx
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L53:
	.cfi_restore_state
	mov	rsi, rdx
	add	esi, esi
	movsx	rsi, esi
	call	realloc@PLT
	mov	rdi, rax
	test	rax, rax
	je	.L51
	mov	QWORD PTR found_ptrs[rip+16], rax
	sal	DWORD PTR found_ptrs[rip]
	mov	QWORD PTR [rdi+rbx], rbp
	add	rsp, 8
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	pop	rbx
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	ret
.L51:
	.cfi_restore_state
	call	extend_ptrs_array.part.0
	.cfi_endproc
.LFE31:
	.size	add_found_ptr, .-add_found_ptr
	.p2align 4
	.globl	add_entry
	.type	add_entry, @function
add_entry:
.LFB32:
	.cfi_startproc
	push	r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	mov	r14, rdi
	push	r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	push	r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	push	rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	push	rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	mov	rbx, rsi
	call	strlen@PLT
	cmp	DWORD PTR longest_entry[rip], eax
	mov	rbp, rax
	mov	r12d, eax
	jge	.L55
	cmp	eax, 45
	jle	.L100
.L55:
	mov	eax, DWORD PTR 8[rbx]
	mov	esi, DWORD PTR [rbx]
	lea	edx, [rax+rbp]
	cmp	edx, esi
	jl	.L56
	mov	rdi, QWORD PTR 24[rbx]
	lea	r13, 24[rbx]
	.p2align 4,,10
	.p2align 3
.L69:
	add	esi, esi
	movsx	rsi, esi
	call	realloc@PLT
	mov	rdi, rax
	test	rax, rax
	je	.L57
	mov	rsi, QWORD PTR 24[rbx]
	cmp	rax, rsi
	je	.L58
	mov	ecx, DWORD PTR 12[rbx]
	test	ecx, ecx
	jle	.L59
	mov	rdx, QWORD PTR 16[rbx]
	mov	rax, QWORD PTR [rdx]
	sub	rax, rsi
	add	rax, rdi
	mov	QWORD PTR [rdx], rax
	cmp	ecx, 1
	je	.L59
	lea	esi, -2[rcx]
	lea	rax, 8[rdx]
	cmp	esi, 1
	jbe	.L65
	mov	eax, ecx
	lea	rax, [rdx+rax*8]
	cmp	r13, rax
	jnb	.L73
	lea	rax, 8[rdx]
	lea	r8, 32[rbx]
	cmp	r8, rax
	jbe	.L73
.L65:
	lea	rcx, 16[rdx+rsi*8]
	.p2align 4,,10
	.p2align 3
.L63:
	mov	rdx, QWORD PTR [rax]
	add	rax, 8
	add	rdx, rdi
	sub	rdx, QWORD PTR 24[rbx]
	mov	QWORD PTR -8[rax], rdx
	cmp	rcx, rax
	jne	.L63
	.p2align 4,,10
	.p2align 3
.L59:
	mov	QWORD PTR 24[rbx], rdi
.L58:
	mov	eax, DWORD PTR [rbx]
	lea	esi, [rax+rax]
	mov	eax, DWORD PTR 8[rbx]
	mov	DWORD PTR [rbx], esi
	lea	edx, [rax+r12]
	cmp	edx, esi
	jge	.L69
.L56:
	movsx	rdx, DWORD PTR 12[rbx]
	movsx	rcx, DWORD PTR 4[rbx]
	sal	rdx, 3
	mov	rsi, rcx
	cmp	rcx, rdx
	jnb	.L70
	mov	rdi, QWORD PTR 16[rbx]
	.p2align 4,,10
	.p2align 3
.L71:
	add	esi, esi
	movsx	rsi, esi
	call	realloc@PLT
	mov	rdi, rax
	test	rax, rax
	je	.L57
	mov	QWORD PTR 16[rbx], rax
	mov	eax, DWORD PTR 4[rbx]
	lea	esi, [rax+rax]
	movsx	rax, DWORD PTR 12[rbx]
	movsx	rdx, esi
	mov	DWORD PTR 4[rbx], esi
	sal	rax, 3
	cmp	rdx, rax
	jb	.L71
	mov	eax, DWORD PTR 8[rbx]
.L70:
	movsx	r12, ebp
	movsx	rcx, eax
	add	rcx, QWORD PTR 24[rbx]
	mov	rsi, r14
	mov	rdx, r12
	mov	rdi, rcx
	add	ebp, 1
	call	memcpy@PLT
	mov	BYTE PTR [rax+r12], 0
	movsx	rsi, DWORD PTR 12[rbx]
	mov	rcx, rax
	mov	rdx, QWORD PTR 16[rbx]
	add	DWORD PTR 8[rbx], ebp
	mov	rax, rsi
	add	eax, 1
	mov	QWORD PTR [rdx+rsi*8], rcx
	mov	DWORD PTR 12[rbx], eax
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	pop	rbp
	.cfi_def_cfa_offset 32
	pop	r12
	.cfi_def_cfa_offset 24
	pop	r13
	.cfi_def_cfa_offset 16
	pop	r14
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L73:
	.cfi_restore_state
	sub	ecx, 1
	movq	xmm0, QWORD PTR 24[rbx]
	movq	xmm1, rdi
	mov	rax, rdx
	mov	esi, ecx
	punpcklqdq	xmm1, xmm1
	shr	esi
	punpcklqdq	xmm0, xmm0
	sal	rsi, 4
	psubq	xmm1, xmm0
	add	rsi, rdx
	.p2align 4,,10
	.p2align 3
.L67:
	movdqu	xmm0, XMMWORD PTR 8[rax]
	add	rax, 16
	paddq	xmm0, xmm1
	movups	XMMWORD PTR -8[rax], xmm0
	cmp	rsi, rax
	jne	.L67
	mov	eax, ecx
	or	eax, 1
	and	ecx, 1
	je	.L59
	cdqe
	lea	rdx, [rdx+rax*8]
	mov	rax, QWORD PTR [rdx]
	add	rax, rdi
	sub	rax, QWORD PTR 24[rbx]
	mov	QWORD PTR [rdx], rax
	jmp	.L59
.L100:
	mov	DWORD PTR longest_entry[rip], eax
	jmp	.L55
.L57:
	lea	rdi, .LC1[rip]
	call	panic
	.cfi_endproc
.LFE32:
	.size	add_entry, .-add_entry
	.section	.rodata.str1.1
.LC5:
	.string	"opendir() error"
	.text
	.p2align 4
	.globl	get_dir_contents
	.type	get_dir_contents, @function
get_dir_contents:
.LFB33:
	.cfi_startproc
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	call	opendir@PLT
	test	rax, rax
	je	.L122
	mov	DWORD PTR dir_array[rip+12], 0
	mov	rbx, rax
	lea	rbp, file_array[rip]
	lea	r12, dir_array[rip]
	mov	DWORD PTR file_array[rip+12], 0
	mov	QWORD PTR found_ptrs[rip+4], 0
	.p2align 4,,10
	.p2align 3
.L103:
	mov	rdi, rbx
	call	readdir@PLT
	test	rax, rax
	je	.L123
.L108:
	cmp	BYTE PTR 19[rax], 46
	lea	rdi, 19[rax]
	jne	.L113
	cmp	BYTE PTR 1[rdi], 0
	je	.L103
.L113:
	cmp	BYTE PTR 19[rax], 46
	jne	.L114
	cmp	BYTE PTR 1[rdi], 46
	jne	.L114
	cmp	BYTE PTR 2[rdi], 0
	je	.L103
	.p2align 4,,10
	.p2align 3
.L114:
	cmp	BYTE PTR 18[rax], 4
	je	.L124
	mov	rsi, rbp
	call	add_entry
	mov	rdi, rbx
	call	readdir@PLT
	test	rax, rax
	jne	.L108
.L123:
	lea	rbx, compare_entries[rip]
	movsx	rsi, DWORD PTR dir_array[rip+12]
	mov	edx, 8
	mov	rdi, QWORD PTR dir_array[rip+16]
	mov	rcx, rbx
	call	qsort@PLT
	movsx	rsi, DWORD PTR file_array[rip+12]
	mov	rcx, rbx
	mov	rdi, QWORD PTR file_array[rip+16]
	mov	edx, 8
	call	qsort@PLT
	movsx	rdx, DWORD PTR dir_array[rip+12]
	mov	ebx, DWORD PTR file_array[rip+12]
	movsx	rax, DWORD PTR all_ptrs[rip]
	add	ebx, edx
	movsx	rbx, ebx
	sal	rbx, 3
	cmp	rax, rbx
	jb	.L109
	mov	rdi, QWORD PTR all_ptrs[rip+16]
.L110:
	mov	rsi, QWORD PTR dir_array[rip+16]
	sal	rdx, 3
	call	memcpy@PLT
	movsx	rdx, DWORD PTR dir_array[rip+12]
	mov	rax, QWORD PTR all_ptrs[rip+16]
	mov	rsi, QWORD PTR file_array[rip+16]
	lea	rdi, [rax+rdx*8]
	movsx	rdx, DWORD PTR file_array[rip+12]
	sal	rdx, 3
	call	memcpy@PLT
	movd	xmm0, DWORD PTR dir_array[rip+12]
	movd	xmm1, DWORD PTR file_array[rip+12]
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	punpckldq	xmm0, xmm1
	pop	r12
	.cfi_def_cfa_offset 8
	movq	QWORD PTR all_ptrs[rip+4], xmm0
	ret
	.p2align 4,,10
	.p2align 3
.L124:
	.cfi_restore_state
	mov	rsi, r12
	call	add_entry
	jmp	.L103
	.p2align 4,,10
	.p2align 3
.L109:
	mov	rdi, QWORD PTR all_ptrs[rip+16]
	mov	rsi, rbx
	call	realloc@PLT
	mov	rdi, rax
	test	rax, rax
	je	.L125
	mov	QWORD PTR all_ptrs[rip+16], rax
.L112:
	mov	DWORD PTR all_ptrs[rip], ebx
	movsx	rdx, DWORD PTR dir_array[rip+12]
	jmp	.L110
.L125:
	mov	rdi, QWORD PTR all_ptrs[rip+16]
	jmp	.L112
.L122:
	lea	rdi, .LC5[rip]
	call	panic
	.cfi_endproc
.LFE33:
	.size	get_dir_contents, .-get_dir_contents
	.p2align 4
	.globl	make_window
	.type	make_window, @function
make_window:
.LFB34:
	.cfi_startproc
	mov	rax, QWORD PTR stdscr[rip]
	test	rax, rax
	je	.L128
	movsx	esi, WORD PTR 4[rax]
	movsx	eax, WORD PTR 6[rax]
	pxor	xmm0, xmm0
	add	eax, 1
	add	esi, 1
	cvtsi2sd	xmm0, eax
	mulsd	xmm0, QWORD PTR .LC6[rip]
	mov	edx, eax
	mov	r9d, esi
	cvttsd2si	r8d, xmm0
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, esi
	mulsd	xmm0, QWORD PTR .LC7[rip]
	sub	edx, r8d
	mov	ecx, edx
	cvttsd2si	edi, xmm0
	shr	ecx, 31
	add	ecx, edx
	sar	ecx
	sub	r9d, edi
	mov	edx, r9d
	shr	edx, 31
	add	edx, r9d
	sar	edx
.L127:
	mov	DWORD PTR termy[rip], esi
	mov	esi, r8d
	mov	DWORD PTR termx[rip], eax
	mov	DWORD PTR winx[rip], r8d
	mov	DWORD PTR winy[rip], edi
	jmp	newwin@PLT
	.p2align 4,,10
	.p2align 3
.L128:
	xor	edx, edx
	xor	ecx, ecx
	xor	edi, edi
	xor	r8d, r8d
	mov	esi, -1
	mov	eax, -1
	jmp	.L127
	.cfi_endproc
.LFE34:
	.size	make_window, .-make_window
	.section	.rodata.str1.1
.LC8:
	.string	"%.*s"
.LC9:
	.string	"..."
	.text
	.p2align 4
	.globl	draw_found_entries
	.type	draw_found_entries, @function
draw_found_entries:
.LFB35:
	.cfi_startproc
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	mov	r15, rsi
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 40
	.cfi_def_cfa_offset 96
	mov	eax, DWORD PTR winx[rip]
	mov	DWORD PTR 8[rsp], edi
	cdq
	idiv	DWORD PTR longest_entry[rip]
	mov	edx, 1
	test	eax, eax
	cmovg	edx, eax
	mov	eax, DWORD PTR 4[rsi]
	mov	DWORD PTR 4[rsp], edx
	test	eax, eax
	jle	.L143
	lea	rsi, .LC8[rip]
	xor	ebp, ebp
	xor	ebx, ebx
	xor	r12d, r12d
	mov	QWORD PTR 16[rsp], rsi
	mov	r14d, 3
	jmp	.L135
	.p2align 4,,10
	.p2align 3
.L151:
	mov	eax, DWORD PTR 12[rsp]
	add	rbp, 1
	lea	r12d, 1[rax+r12]
	mov	eax, DWORD PTR 4[r15]
	cmp	eax, ebp
	jle	.L130
.L135:
	cmp	DWORD PTR 8[rsp], ebp
	mov	eax, 512
	mov	r13d, 256
	mov	rdi, QWORD PTR win[rip]
	cmovne	r13d, eax
	xor	edx, edx
	mov	esi, r13d
	call	wattr_on@PLT
	mov	rax, QWORD PTR 16[r15]
	mov	edx, r12d
	mov	esi, r14d
	mov	rdi, QWORD PTR win[rip]
	mov	r8d, DWORD PTR longest_entry[rip]
	mov	r9, QWORD PTR [rax+rbp*8]
	mov	rcx, QWORD PTR 16[rsp]
	xor	eax, eax
	call	mvwprintw@PLT
	mov	rax, QWORD PTR 16[r15]
	mov	rdi, QWORD PTR [rax+rbp*8]
	call	strlen@PLT
	cmp	eax, 45
	jg	.L150
.L132:
	mov	eax, DWORD PTR longest_entry[rip]
	xor	edx, edx
	mov	esi, r13d
	add	ebx, 1
	mov	rdi, QWORD PTR win[rip]
	mov	DWORD PTR 12[rsp], eax
	call	wattr_off@PLT
	cmp	DWORD PTR 4[rsp], ebx
	jg	.L151
	mov	eax, DWORD PTR 4[r15]
	add	rbp, 1
	add	r14d, 1
	xor	ebx, ebx
	xor	r12d, r12d
	cmp	eax, ebp
	jg	.L135
.L130:
	mov	edx, DWORD PTR 8[r15]
	movsx	r13, eax
	lea	rsi, .LC8[rip]
	sal	r13, 3
	test	edx, edx
	jle	.L129
	mov	DWORD PTR 12[rsp], r14d
	mov	ebp, eax
	mov	QWORD PTR 24[rsp], rsi
	jmp	.L141
	.p2align 4,,10
	.p2align 3
.L153:
	mov	eax, DWORD PTR 16[rsp]
	lea	r12d, 1[rax+r12]
.L140:
	mov	eax, DWORD PTR 4[r15]
	add	ebp, 1
	add	eax, DWORD PTR 8[r15]
	add	r13, 8
	cmp	eax, ebp
	jle	.L129
.L141:
	mov	eax, DWORD PTR 8[rsp]
	mov	edx, 256
	mov	rdi, QWORD PTR win[rip]
	cmp	ebp, eax
	mov	eax, 512
	cmove	eax, edx
	xor	edx, edx
	mov	esi, eax
	mov	r14d, eax
	call	wattr_on@PLT
	mov	rax, QWORD PTR 16[r15]
	mov	esi, DWORD PTR 12[rsp]
	mov	edx, r12d
	mov	rdi, QWORD PTR win[rip]
	mov	r8d, DWORD PTR longest_entry[rip]
	mov	r9, QWORD PTR [rax+r13]
	mov	rcx, QWORD PTR 24[rsp]
	xor	eax, eax
	call	mvwprintw@PLT
	mov	rax, QWORD PTR 16[r15]
	mov	rdi, QWORD PTR [rax+r13]
	call	strlen@PLT
	cmp	eax, 45
	jg	.L152
.L138:
	mov	eax, DWORD PTR longest_entry[rip]
	xor	edx, edx
	mov	esi, r14d
	add	ebx, 1
	mov	rdi, QWORD PTR win[rip]
	mov	DWORD PTR 16[rsp], eax
	call	wattr_off@PLT
	cmp	DWORD PTR 4[rsp], ebx
	jg	.L153
	add	DWORD PTR 12[rsp], 1
	xor	ebx, ebx
	xor	r12d, r12d
	jmp	.L140
	.p2align 4,,10
	.p2align 3
.L150:
	mov	edx, DWORD PTR longest_entry[rip]
	mov	rdi, QWORD PTR win[rip]
	mov	esi, r14d
	xor	eax, eax
	lea	rcx, .LC9[rip]
	add	edx, r12d
	sub	edx, 3
	call	mvwprintw@PLT
	jmp	.L132
	.p2align 4,,10
	.p2align 3
.L152:
	mov	edx, DWORD PTR longest_entry[rip]
	mov	esi, DWORD PTR 12[rsp]
	lea	rcx, .LC9[rip]
	xor	eax, eax
	mov	rdi, QWORD PTR win[rip]
	add	edx, r12d
	sub	edx, 3
	call	mvwprintw@PLT
	jmp	.L138
	.p2align 4,,10
	.p2align 3
.L129:
	add	rsp, 40
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L143:
	.cfi_restore_state
	xor	ebx, ebx
	mov	r14d, 3
	xor	r12d, r12d
	jmp	.L130
	.cfi_endproc
.LFE35:
	.size	draw_found_entries, .-draw_found_entries
	.p2align 4
	.globl	draw_entries
	.type	draw_entries, @function
draw_entries:
.LFB36:
	.cfi_startproc
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 24
	.cfi_def_cfa_offset 80
	mov	eax, DWORD PTR winx[rip]
	mov	DWORD PTR 12[rsp], edi
	cdq
	idiv	DWORD PTR longest_entry[rip]
	mov	edx, 1
	test	eax, eax
	cmovg	edx, eax
	mov	eax, DWORD PTR dir_array[rip+12]
	mov	DWORD PTR 8[rsp], edx
	test	eax, eax
	jle	.L167
	lea	rax, .LC8[rip]
	xor	ebp, ebp
	xor	ebx, ebx
	xor	r12d, r12d
	mov	QWORD PTR [rsp], rax
	mov	r14d, 3
	jmp	.L160
	.p2align 4,,10
	.p2align 3
.L157:
	mov	r15d, DWORD PTR longest_entry[rip]
	xor	edx, edx
	mov	esi, r13d
	add	ebx, 1
	mov	rdi, QWORD PTR win[rip]
	lea	r12d, 1[r15+r12]
	call	wattr_off@PLT
	cmp	DWORD PTR 8[rsp], ebx
	jg	.L159
	add	r14d, 1
	xor	ebx, ebx
	xor	r12d, r12d
.L159:
	mov	eax, DWORD PTR dir_array[rip+12]
	add	rbp, 1
	cmp	eax, ebp
	jle	.L155
.L160:
	cmp	DWORD PTR 12[rsp], ebp
	mov	eax, 512
	mov	r13d, 256
	mov	rdi, QWORD PTR win[rip]
	cmovne	r13d, eax
	xor	edx, edx
	mov	esi, r13d
	call	wattr_on@PLT
	mov	rcx, QWORD PTR [rsp]
	mov	edx, r12d
	mov	esi, r14d
	mov	rax, QWORD PTR dir_array[rip+16]
	mov	rdi, QWORD PTR win[rip]
	mov	r8d, DWORD PTR longest_entry[rip]
	mov	r9, QWORD PTR [rax+rbp*8]
	xor	eax, eax
	call	mvwprintw@PLT
	mov	rax, QWORD PTR dir_array[rip+16]
	mov	rdi, QWORD PTR [rax+rbp*8]
	call	strlen@PLT
	cmp	eax, 45
	jle	.L157
	mov	edx, DWORD PTR longest_entry[rip]
	mov	rdi, QWORD PTR win[rip]
	mov	esi, r14d
	xor	eax, eax
	lea	rcx, .LC9[rip]
	add	edx, r12d
	sub	edx, 3
	call	mvwprintw@PLT
	jmp	.L157
	.p2align 4,,10
	.p2align 3
.L167:
	xor	ebx, ebx
	mov	r14d, 3
	xor	r12d, r12d
	.p2align 4,,10
	.p2align 3
.L155:
	mov	edx, DWORD PTR file_array[rip+12]
	test	edx, edx
	jle	.L161
	lea	rcx, .LC8[rip]
	xor	ebp, ebp
	mov	QWORD PTR [rsp], rcx
	jmp	.L166
	.p2align 4,,10
	.p2align 3
.L163:
	mov	r15d, DWORD PTR longest_entry[rip]
	xor	edx, edx
	mov	esi, r13d
	add	ebx, 1
	mov	rdi, QWORD PTR win[rip]
	lea	r12d, 1[r15+r12]
	call	wattr_off@PLT
	cmp	DWORD PTR 8[rsp], ebx
	jg	.L165
	add	r14d, 1
	xor	ebx, ebx
	xor	r12d, r12d
.L165:
	add	rbp, 1
	cmp	DWORD PTR file_array[rip+12], ebp
	jle	.L161
	mov	eax, DWORD PTR dir_array[rip+12]
.L166:
	mov	ecx, DWORD PTR 12[rsp]
	add	eax, ebp
	mov	r13d, 256
	mov	rdi, QWORD PTR win[rip]
	cmp	eax, ecx
	mov	eax, 512
	cmovne	r13d, eax
	xor	edx, edx
	mov	esi, r13d
	call	wattr_on@PLT
	mov	rcx, QWORD PTR [rsp]
	mov	edx, r12d
	mov	esi, r14d
	mov	rax, QWORD PTR file_array[rip+16]
	mov	rdi, QWORD PTR win[rip]
	mov	r8d, DWORD PTR longest_entry[rip]
	mov	r9, QWORD PTR [rax+rbp*8]
	xor	eax, eax
	call	mvwprintw@PLT
	mov	rax, QWORD PTR file_array[rip+16]
	mov	rdi, QWORD PTR [rax+rbp*8]
	call	strlen@PLT
	cmp	eax, 45
	jle	.L163
	mov	edx, DWORD PTR longest_entry[rip]
	mov	rdi, QWORD PTR win[rip]
	mov	esi, r14d
	xor	eax, eax
	lea	rcx, .LC9[rip]
	add	edx, r12d
	sub	edx, 3
	call	mvwprintw@PLT
	jmp	.L163
	.p2align 4,,10
	.p2align 3
.L161:
	mov	rdi, QWORD PTR win[rip]
	xor	edx, edx
	xor	esi, esi
	call	wmove@PLT
	mov	rdi, QWORD PTR stdscr[rip]
	call	wrefresh@PLT
	mov	rdi, QWORD PTR win[rip]
	add	rsp, 24
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	jmp	wrefresh@PLT
	.cfi_endproc
.LFE36:
	.size	draw_entries, .-draw_entries
	.section	.rodata.str1.1
.LC10:
	.string	"wcstombs error"
	.text
	.p2align 4
	.globl	search_entries
	.type	search_entries, @function
search_entries:
.LFB37:
	.cfi_startproc
	push	r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	mov	rsi, rdi
	mov	edx, 255
	push	r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	push	r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	lea	r12, multi_byte.0[rip]
	push	rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	mov	rdi, r12
	push	rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	call	wcstombs@PLT
	cmp	eax, -1
	je	.L202
	mov	r13d, DWORD PTR dir_array[rip+12]
	xor	ebx, ebx
	mov	QWORD PTR found_ptrs[rip+4], 0
	test	r13d, r13d
	jg	.L174
	jmp	.L180
	.p2align 4,,10
	.p2align 3
.L178:
	add	edx, 1
	mov	QWORD PTR [rdi+rbp], r14
	mov	DWORD PTR found_ptrs[rip+4], edx
.L177:
	add	rbx, 1
	cmp	r13d, ebx
	jle	.L180
.L174:
	mov	rax, QWORD PTR dir_array[rip+16]
	mov	rsi, r12
	mov	r14, QWORD PTR [rax+rbx*8]
	mov	rdi, r14
	call	strcasestr@PLT
	test	rax, rax
	je	.L177
	mov	edx, DWORD PTR found_ptrs[rip+4]
	mov	ebp, DWORD PTR found_ptrs[rip+8]
	movsx	rcx, DWORD PTR found_ptrs[rip]
	mov	rdi, QWORD PTR found_ptrs[rip+16]
	add	ebp, edx
	sal	ebp, 3
	mov	rsi, rcx
	movsx	rbp, ebp
	lea	rax, 8[rbp]
	cmp	rcx, rax
	jnb	.L178
	add	esi, esi
	movsx	rsi, esi
	call	realloc@PLT
	mov	rdi, rax
	test	rax, rax
	je	.L179
	mov	QWORD PTR found_ptrs[rip+16], rax
	mov	edx, DWORD PTR found_ptrs[rip+4]
	mov	r13d, DWORD PTR dir_array[rip+12]
	sal	DWORD PTR found_ptrs[rip]
	jmp	.L178
	.p2align 4,,10
	.p2align 3
.L180:
	mov	r13d, DWORD PTR file_array[rip+12]
	xor	ebx, ebx
	test	r13d, r13d
	jg	.L175
	jmp	.L172
	.p2align 4,,10
	.p2align 3
.L182:
	add	edx, 1
	mov	QWORD PTR [rdi+rbp], r14
	mov	DWORD PTR found_ptrs[rip+8], edx
.L181:
	add	rbx, 1
	cmp	r13d, ebx
	jle	.L172
.L175:
	mov	rax, QWORD PTR file_array[rip+16]
	mov	rsi, r12
	mov	r14, QWORD PTR [rax+rbx*8]
	mov	rdi, r14
	call	strcasestr@PLT
	test	rax, rax
	je	.L181
	mov	edx, DWORD PTR found_ptrs[rip+8]
	mov	ebp, DWORD PTR found_ptrs[rip+4]
	movsx	rcx, DWORD PTR found_ptrs[rip]
	mov	rdi, QWORD PTR found_ptrs[rip+16]
	add	ebp, edx
	sal	ebp, 3
	mov	rsi, rcx
	movsx	rbp, ebp
	lea	rax, 8[rbp]
	cmp	rcx, rax
	jnb	.L182
	add	esi, esi
	movsx	rsi, esi
	call	realloc@PLT
	mov	rdi, rax
	test	rax, rax
	je	.L179
	mov	QWORD PTR found_ptrs[rip+16], rax
	mov	edx, DWORD PTR found_ptrs[rip+8]
	mov	r13d, DWORD PTR file_array[rip+12]
	sal	DWORD PTR found_ptrs[rip]
	jmp	.L182
	.p2align 4,,10
	.p2align 3
.L172:
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	pop	rbp
	.cfi_def_cfa_offset 32
	pop	r12
	.cfi_def_cfa_offset 24
	pop	r13
	.cfi_def_cfa_offset 16
	pop	r14
	.cfi_def_cfa_offset 8
	ret
.L179:
	.cfi_restore_state
	call	extend_ptrs_array.part.0
.L202:
	lea	rdi, .LC10[rip]
	call	panic
	.cfi_endproc
.LFE37:
	.size	search_entries, .-search_entries
	.section	.rodata.str1.1
.LC11:
	.string	"chdir error"
	.text
	.p2align 4
	.globl	change_directory
	.type	change_directory, @function
change_directory:
.LFB38:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	call	chdir@PLT
	test	eax, eax
	jne	.L204
	lea	rbx, current_path[rip]
	mov	esi, 4096
	mov	rdi, rbx
	call	getcwd@PLT
	mov	rdi, rbx
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	jmp	get_dir_contents
.L204:
	.cfi_restore_state
	lea	rdi, .LC11[rip]
	call	panic
	.cfi_endproc
.LFE38:
	.size	change_directory, .-change_directory
	.section	.rodata.str1.1
.LC14:
	.string	"Time elapsed: %f milliseconds"
	.text
	.p2align 4
	.globl	entry_search_loop
	.type	entry_search_loop, @function
entry_search_loop:
.LFB39:
	.cfi_startproc
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	mov	ecx, 127
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	lea	r14, all_ptrs[rip]
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	mov	rsi, r14
	xor	r13d, r13d
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	mov	r12, r14
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	xor	ebp, ebp
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 1096
	.cfi_def_cfa_offset 1152
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 1080[rsp], rax
	xor	eax, eax
	lea	rdi, 48[rsp]
	mov	DWORD PTR 44[rsp], 0
	mov	QWORD PTR 24[rsp], rdi
	rep stosq
	mov	DWORD PTR [rdi], 0
	xor	edi, edi
	call	draw_found_entries
	mov	rdi, QWORD PTR win[rip]
	xor	edx, edx
	xor	esi, esi
	call	wmove@PLT
	mov	rdi, QWORD PTR stdscr[rip]
	call	wrefresh@PLT
	mov	rdi, QWORD PTR win[rip]
	call	wrefresh@PLT
	lea	rax, 44[rsp]
	mov	QWORD PTR 16[rsp], r14
	mov	QWORD PTR 8[rsp], rax
	jmp	.L222
	.p2align 4,,10
	.p2align 3
.L248:
	mov	rdi, QWORD PTR 24[rsp]
	lea	r12, found_ptrs[rip]
	mov	r15d, r13d
	call	search_entries
	mov	eax, DWORD PTR found_ptrs[rip+8]
	mov	rsi, r12
	add	eax, DWORD PTR found_ptrs[rip+4]
	cmp	eax, ebp
	mov	eax, 0
	cmovb	ebp, eax
	mov	edi, ebp
	call	draw_found_entries
.L221:
	mov	rdi, QWORD PTR win[rip]
	mov	edx, r15d
	xor	esi, esi
	call	wmove@PLT
	mov	rdi, QWORD PTR stdscr[rip]
	call	wrefresh@PLT
	mov	rdi, QWORD PTR win[rip]
	call	wrefresh@PLT
	call	clock@PLT
	pxor	xmm0, xmm0
	xor	edx, edx
	mov	esi, 2
	sub	rax, rbx
	mov	rdi, QWORD PTR win[rip]
	lea	rcx, .LC14[rip]
	cvtsi2sd	xmm0, rax
	divsd	xmm0, QWORD PTR .LC12[rip]
	mov	eax, 1
	mulsd	xmm0, QWORD PTR .LC13[rip]
	call	mvwprintw@PLT
	mov	rdi, QWORD PTR win[rip]
	mov	edx, r15d
	xor	esi, esi
	call	wmove@PLT
	mov	rdi, QWORD PTR win[rip]
	call	wrefresh@PLT
.L222:
	call	clock@PLT
	mov	rsi, QWORD PTR 8[rsp]
	mov	rdi, QWORD PTR stdscr[rip]
	mov	rbx, rax
	call	wget_wch@PLT
	mov	eax, DWORD PTR 44[rsp]
	cmp	eax, 27
	je	.L243
	cmp	eax, 410
	je	.L244
	cmp	eax, 10
	je	.L245
	cmp	eax, 9
	je	.L246
	cmp	eax, 353
	je	.L247
	cmp	eax, 263
	sete	dl
	cmp	eax, 127
	sete	cl
	or	dl, cl
	jne	.L228
	cmp	eax, 8
	je	.L228
	mov	edx, r13d
	xor	ebp, ebp
	mov	DWORD PTR 48[rsp+rdx*4], eax
	lea	eax, 1[r13]
	xor	edx, edx
	mov	DWORD PTR 48[rsp+rax*4], edx
	mov	r13, rax
	.p2align 4,,10
	.p2align 3
.L210:
	mov	rdi, QWORD PTR win[rip]
	call	werase@PLT
	mov	rdi, QWORD PTR win[rip]
	xor	edx, edx
	xor	esi, esi
	call	wmove@PLT
	cmp	eax, -1
	je	.L218
	mov	rsi, QWORD PTR 24[rsp]
	mov	rdi, QWORD PTR win[rip]
	mov	edx, -1
	call	waddnwstr@PLT
.L218:
	test	r13d, r13d
	jne	.L248
.L219:
	mov	rsi, QWORD PTR 16[rsp]
	mov	edi, ebp
	xor	r15d, r15d
	xor	r13d, r13d
	mov	r12, r14
	call	draw_found_entries
	mov	QWORD PTR 16[rsp], r14
	jmp	.L221
	.p2align 4,,10
	.p2align 3
.L244:
	mov	rax, QWORD PTR stdscr[rip]
	test	rax, rax
	je	.L225
	movsx	edx, WORD PTR 4[rax]
	movsx	eax, WORD PTR 6[rax]
	pxor	xmm0, xmm0
	add	eax, 1
	add	edx, 1
	cvtsi2sd	xmm0, eax
	mulsd	xmm0, QWORD PTR .LC6[rip]
	cvttsd2si	ecx, xmm0
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, edx
	mulsd	xmm0, QWORD PTR .LC7[rip]
	cvttsd2si	esi, xmm0
.L209:
	mov	rdi, QWORD PTR win[rip]
	mov	DWORD PTR termy[rip], edx
	mov	edx, ecx
	mov	DWORD PTR winx[rip], ecx
	mov	DWORD PTR winy[rip], esi
	mov	DWORD PTR termx[rip], eax
	call	wresize@PLT
	jmp	.L210
	.p2align 4,,10
	.p2align 3
.L245:
	cmp	ebp, DWORD PTR 4[r12]
	jnb	.L210
	mov	rdx, QWORD PTR 16[r12]
	mov	eax, ebp
	mov	rdi, QWORD PTR [rdx+rax*8]
	call	change_directory
	xor	esi, esi
	mov	DWORD PTR 48[rsp], esi
.L212:
	mov	rdi, QWORD PTR win[rip]
	call	werase@PLT
	mov	rdi, QWORD PTR win[rip]
	xor	edx, edx
	xor	esi, esi
	call	wmove@PLT
	cmp	eax, -1
	je	.L219
	mov	rsi, QWORD PTR 24[rsp]
	mov	rdi, QWORD PTR win[rip]
	or	edx, -1
	call	waddnwstr@PLT
	jmp	.L219
	.p2align 4,,10
	.p2align 3
.L246:
	mov	eax, DWORD PTR 8[r12]
	add	eax, DWORD PTR 4[r12]
	lea	edx, 1[rbp]
	sub	eax, 1
	cmp	eax, ebp
	mov	ebp, 0
	cmovne	ebp, edx
	jmp	.L210
	.p2align 4,,10
	.p2align 3
.L228:
	test	r13d, r13d
	je	.L212
	lea	eax, -1[r13]
	xor	ecx, ecx
	xor	ebp, ebp
	mov	DWORD PTR 48[rsp+rax*4], ecx
	mov	r13, rax
	jmp	.L210
	.p2align 4,,10
	.p2align 3
.L243:
	mov	rdi, QWORD PTR win[rip]
	call	delwin@PLT
	call	endwin@PLT
	xor	edi, edi
	call	exit@PLT
	.p2align 4,,10
	.p2align 3
.L225:
	xor	esi, esi
	xor	ecx, ecx
	mov	edx, -1
	mov	eax, -1
	jmp	.L209
	.p2align 4,,10
	.p2align 3
.L247:
	test	ebp, ebp
	je	.L215
.L242:
	sub	ebp, 1
	jmp	.L210
.L215:
	mov	ebp, DWORD PTR 8[r12]
	add	ebp, DWORD PTR 4[r12]
	jmp	.L242
	.cfi_endproc
.LFE39:
	.size	entry_search_loop, .-entry_search_loop
	.section	.rodata.str1.1
.LC15:
	.string	""
.LC16:
	.string	"/usr/share/man/man3"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB41:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	call	clock@PLT
	lea	rsi, sigint_handler[rip]
	mov	edi, 2
	mov	rbx, rax
	call	signal@PLT
	lea	rsi, .LC15[rip]
	mov	edi, 6
	call	setlocale@PLT
	call	initscr@PLT
	call	cbreak@PLT
	call	noecho@PLT
	mov	rdi, QWORD PTR stdscr[rip]
	mov	esi, 1
	call	keypad@PLT
	call	start_color@PLT
	call	use_default_colors@PLT
	mov	ecx, 173
	mov	edx, 56
	mov	esi, 2
	mov	edi, 4
	call	init_color@PLT
	mov	edx, 7
	mov	esi, 4
	mov	edi, 1
	call	init_pair@PLT
	mov	edx, 4
	mov	esi, 7
	mov	edi, 2
	call	init_pair@PLT
	xor	eax, eax
	call	make_window
	mov	QWORD PTR win[rip], rax
	xor	eax, eax
	call	init
	lea	rdi, .LC16[rip]
	call	get_dir_contents
	mov	rdi, QWORD PTR win[rip]
	xor	edx, edx
	xor	esi, esi
	call	wmove@PLT
	call	clock@PLT
	pxor	xmm0, xmm0
	xor	edx, edx
	mov	esi, 2
	sub	rax, rbx
	mov	rdi, QWORD PTR win[rip]
	lea	rcx, .LC14[rip]
	cvtsi2sd	xmm0, rax
	divsd	xmm0, QWORD PTR .LC12[rip]
	mov	eax, 1
	mulsd	xmm0, QWORD PTR .LC13[rip]
	call	mvwprintw@PLT
	xor	eax, eax
	call	entry_search_loop
	.cfi_endproc
.LFE41:
	.size	main, .-main
	.local	multi_byte.0
	.comm	multi_byte.0,255,32
	.globl	winy
	.bss
	.align 4
	.type	winy, @object
	.size	winy, 4
winy:
	.zero	4
	.globl	winx
	.align 4
	.type	winx, @object
	.size	winx, 4
winx:
	.zero	4
	.globl	termy
	.align 4
	.type	termy, @object
	.size	termy, 4
termy:
	.zero	4
	.globl	termx
	.align 4
	.type	termx, @object
	.size	termx, 4
termx:
	.zero	4
	.globl	win
	.align 8
	.type	win, @object
	.size	win, 8
win:
	.zero	8
	.globl	longest_entry
	.align 4
	.type	longest_entry, @object
	.size	longest_entry, 4
longest_entry:
	.zero	4
	.globl	user_shell
	.align 8
	.type	user_shell, @object
	.size	user_shell, 8
user_shell:
	.zero	8
	.globl	current_path_length
	.align 4
	.type	current_path_length, @object
	.size	current_path_length, 4
current_path_length:
	.zero	4
	.globl	current_path
	.align 32
	.type	current_path, @object
	.size	current_path, 4096
current_path:
	.zero	4096
	.globl	all_ptrs
	.align 16
	.type	all_ptrs, @object
	.size	all_ptrs, 24
all_ptrs:
	.zero	24
	.globl	found_ptrs
	.align 16
	.type	found_ptrs, @object
	.size	found_ptrs, 24
found_ptrs:
	.zero	24
	.globl	dir_array
	.align 32
	.type	dir_array, @object
	.size	dir_array, 32
dir_array:
	.zero	32
	.globl	file_array
	.align 32
	.type	file_array, @object
	.size	file_array, 32
file_array:
	.zero	32
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC3:
	.long	512
	.long	512
	.long	0
	.long	0
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC6:
	.long	-1717986918
	.long	1072273817
	.align 8
.LC7:
	.long	-858993459
	.long	1072483532
	.align 8
.LC12:
	.long	0
	.long	1093567616
	.align 8
.LC13:
	.long	0
	.long	1083129856
	.ident	"GCC: (GNU) 13.2.1 20230801"
	.section	.note.GNU-stack,"",@progbits
