global main

; Using Intel syntax
section .text

; [rbp - 16] = loop counter
; [rbp - 24] = msg index
printArray:
	push rbp
	mov rbp, rsp
	sub rsp, 16

	mov rax, 0x00
	mov [rbp - 16], rax
	mov [rbp - 24], DWORD(0x01)
	printArray_loop:
		mov rax, [rbp - 16]
		cmp rax, BYTE(0x04) ; len_array / size
		je printArray_print

		mov rbx, array
		add rbx, [rbp - 16]
		mov bl, BYTE[rbx]
		add bl, 0x30 ; ASCII offset for numbers
		mov rax, [rbp - 24]
		add rax, msg
		mov [rax], bl

		mov rax, [rbp - 16]
		add rax, 1
		mov [rbp - 16], rax

		mov rax, [rbp - 24]
		add rax, 2
		mov [rbp - 24], rax

		jmp printArray_loop

	printArray_print:
		mov rax, 1			 ; write syscall (x86_64)
		mov rdi, 1			 ; fd = stdout
		mov rsi, msg		 ; address to find the string to be printed
		mov rdx, len_msg ; length of the text to be printed
		syscall

		add rsp, 16
		pop rbp
		ret

;rbp + 16: pivot
print_pivot:
	push rbp
	mov rbp, rsp

	mov rax, pivot_string

	mov bl, BYTE[rbp + 16]
	add bl, 0x30 ; ASCII offset
	add rax, BYTE(0x06)
	mov [rax], bl

	mov rax, 1
	mov rdi, 1
	mov rsi, pivot_string
	mov rdx, len_pivot_string
	syscall

	pop rbp
	ret

;rbp + 16: ptr's value
;rbp + 24: ptr's string
print_ptr:
	push rbp
	mov rbp, rsp

	mov rax, [rbp + 16]

	mov bl, BYTE[rbp + 24]
	add bl, 0x30 ; ASCII offset
	add rax, BYTE(0x02)
	mov [rax], bl

	mov rax, 1
	mov rdi, 1
	mov rsi, [rbp + 16]
	mov rdx, 0x04
	syscall

	pop rbp
	ret

; rbp+16: a
; rbp+24: b
print_swap:
	push rbp
	mov rbp, rsp

	mov rax, swapping

	mov bl, BYTE[rbp + 16]
	add bl, 0x30 ; ASCII offset
	add rax, BYTE(0x09)
	mov [rax], bl

	mov bl, BYTE[rbp + 24]
	add bl, 0x30 ; ASCII offset
	add rax, BYTE(0x02)
	mov [rax], bl

	mov rax, 1
	mov rdi, 1
	mov rsi, swapping
	mov rdx, len_swapping
	syscall

	pop rbp
	ret

; swaps the values stored at two memory locations
; rbp+16: pointer a
; rbp+24: pointer b
swap:
  push rbp
  mov rbp, rsp

  mov rax, [rbp + 16]
  mov rbx, [rbp + 24]
  movzx rcx, BYTE[rax] ; the value pointer a points to
  movzx rdx, BYTE[rbx] ; the value pointer b points to
  mov BYTE[rax], dl
  mov BYTE[rbx], cl

	push rdx
	push rcx
	call print_swap
	pop rax
	pop rax

  pop rbp
  ret

; rbp+24: the length
; rbp+16: the array
sort:
  push rbp
  mov rbp, rsp

	; check length of array
  cmp [rbp+24], DWORD(0x2)
  jz lengthTwo 	; if length == 2
  jg lengthN		; if length > 2
  jmp done_sort	; else

	lengthTwo:
		mov rax, 1
		mov rdi, 1
		mov rsi, just_two_string
		mov rdx, len_just_two_string
		syscall

	  mov rax, [rbp+16]
	  movzx rbx, BYTE[rax] ; get first value

	  add rax, 1
	  movzx rax, BYTE[rax] ; get second value

	  cmp rax, rbx
	  jg done_sort

	  mov rax, [rbp+16]
	  push rax
	  add rax, 1
	  push rax
	  call swap
	  pop rax
	  pop rax

	  jmp done_sort

	lengthN:
	  sub rsp, 24

		; pivot - the first value in the array
	  mov rax, [rbp + 16]
	  movzx rax, BYTE[rax]
	  mov [rbp - 8], rax
		push rax
		call print_pivot
		pop rax

		; left
	  mov [rbp - 16], DWORD(0x0)
		mov rax, [rbp - 16]
		push rax
		push left_string
		call print_ptr
		pop rax
		pop rax

		; right
	  mov rax, [rbp + 24]
	  sub rax, 1
	  mov [rbp - 24], rax
		push rax
		push right_string
		call print_ptr
		pop rax
		pop rax

	  loop_lengthN:

	    loop_leftLoop:
	      mov rax, [rbp + 16]
	      add rax, [rbp - 16]
	      movzx rax, BYTE[rax]
	      mov rbx, [rbp - 8]
	      cmp rax, rbx
	      jge loop_rightLoop

	      mov rax, [rbp - 16]
	      add rax, 1
	      mov [rbp - 16], rax
				push rax
				push left_string
				call print_ptr
				pop rax
				pop rax
	      jmp loop_leftLoop

	    loop_rightLoop:
	      mov rax, [rbp + 16]
	      add rax, [rbp - 24]
	      movzx rax, BYTE[rax]
	      mov rbx, [rbp - 8]
	      cmp rax, rbx
	      jle loop_swapIfNeeded

	      mov rax, [rbp - 24]
	      sub rax, 1
	      mov [rbp - 24], rax
				push rax
				push right_string
				call print_ptr
				pop rax
				pop rax
	      jmp loop_rightLoop

	    loop_swapIfNeeded:
	      mov rax, [rbp - 16] ; left
	      mov rbx, [rbp - 24] ; right
	      cmp rax, rbx
	      jg loop_endCondition
	      mov rcx, [rbp + 16]
	      add rax, rcx
	      add rbx, rcx
	      push rax
	      push rbx
	      call swap
	      pop rax
	      pop rax
	      ; increment left and decrement right
	      mov rax, [rbp - 16]
	      add rax, 1
	      mov [rbp - 16], rax
	      mov rax, [rbp - 24]
	      sub rax, 1
	      mov [rbp - 24], rax

	    loop_endCondition:
	      mov rax, [rbp - 16]
	      mov rbx, [rbp - 24]
	      cmp rax, rbx
	      jle loop_lengthN
	      ; first recursive call
	      mov rax, [rbp - 24]
	      add rax, 1
	      push rax
	      mov rax, [rbp + 16]
	      push rax
	      call sort
	      pop rax
	      pop rax
	      ; second recursive call
	      mov rax, [rbp + 24]
	      sub rax, [rbp - 16]
	      push rax
	      mov rax, [rbp + 16]
	      add rax, [rbp - 16]
	      push rax
	      call sort
	      pop rax
	      pop rax

  done_lengthN:
    add rsp, 24

done_sort:
  pop rbp
  ret

main:
  call printArray

  movzx rax, BYTE[size]
  push rax
  push array
  call sort
  pop rax
  pop rax

  call printArray

  mov rax,60			; exit syscall (x86_64)
	mov rdi,0			  ; status = 0 (exit normally)
	syscall


section .data
msg: db 0x5B, 0x20, 0x2C, 0x20, 0x2C, 0x20, 0x2C, 0x20, 0x5D, 0x0A
len_msg: equ $-msg
swapping: db 0x53, 0x57, 0x41, 0x50, 0x50, 0x49, 0x4E, 0x47, 0x3A, 0x20, 0x26, 0x20, 0x0A
len_swapping: equ $-swapping
pivot_string: db 0x50, 0x49, 0x56, 0x4F, 0x54, 0x3A, 0x20, 0x0A
len_pivot_string: equ $-pivot_string
just_two_string: db 0x4A, 0x55, 0x53, 0x54, 0x20, 0x54, 0x57, 0x4F, 0x0A
len_just_two_string: equ $-just_two_string
left_string: db 0x4C, 0x3A, 0x20, 0x0A
right_string: db 0x52, 0x3A, 0x20, 0x0A
array:
   db  0x4
   db  0x3
   db  0x2
   db  0x1
len_array: equ $-array
size dd 0x4
