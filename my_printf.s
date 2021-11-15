
.data
auxiliar: .skip 20 #resering 20 bytes for doing the string-to-number conversion
auxiliar_end:
message: .asciz "%d. I think I will get a %u zebra. %r. %d. %s %%. \n %s \n %d\n"
input: .asciz "aaa"
minus: .asciz "-"
input2: .asciz "BBB"
percentage: .asciz "%" 


.text
.global main

main:

	pushq %rbp 
	movq %rsp, %rbp 

	pushq %r15
	pushq %r12 
	movq $message, %rdi
 
	movq $-420, %rsi
	movq $10, %rdx
	movq $111, %rcx
	movq $input2, %r8 
	movq $input, %r9

	#pushq $... (can add more argumtes from here until r8 and after that inside the stack)
	pushq $10


	movq $0, %r15

	call my_printf
	movq %rbp, %rsp
	popq %rbp

	popq %r12
	popq %r15

	movq $60, %rax				#exit
	movq $1, %rdi 
	syscall

	#r12 - the argumet that will be printed (see compare)
	#r15 - the order of the argumet (inside the stack)
	#r9 - length of the strinig that will be printed
	#rsi - the initial message without the formating

my_printf:
	
	pushq %rbp 					#epilogue	
	movq %rsp, %rbp 

	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9

	movq $1, %r15				#if we don't intend to print anything special this won't affect us

loop:
	
	cmpb $37, (%rdi)			#if it havs a '%' we need to see what argument to print 
	je compare

	cmpb $0, (%rdi)				#if we get to 0 then we have finished goign through argument 0
	je exit_print

	 
	movq $1, %rdx
	movq $1, %rax 				#otherwise we just print the character without 
	leaq (%rdi), %rsi 
	pushq %rdi 
	movq $1, %rdi
	syscall 
	popq %rdi 
	incq %rdi
	jmp loop

compare:
	incq %rdi
	cmpb $37, (%rdi) 			#checking which element inside the stack we need to print
	je print_per

	cmp $5, %r15 
	jg above_rbp 
	jmp under_rbp 

	under_rbp:
	movq $8, %rax  				#if its position is <= 5 we go under the new rbp
	mulq %r15
	neg %rax
	addq %rbp, %rax
	movq (%rax), %r12
	jmp print_type

	above_rbp: 					#otherwise we go above it
	subq $4, %r15 
	movq $8, %rax 
	mulq %r15
	addq %rbp, %rax 
	movq (%rax), %r12 

print_type:

	cmpb $100, (%rdi)
	je print_si
	cmpb $117, (%rdi)
	je string_convert			#we check what type of argument is expected to print
	cmpb $115, (%rdi)
	je print_str

	movq $1, %rax
	movq $percentage, %rsi 			#if it's none of them, we print the character alongside the '%' 
	pushq %rdi 						#printing the % character
	movq $1, %rdi 
	movq $1, %rdx 
	syscall 
	popq %rdi

	movq $1, %rax
	leaq (%rdi), %rsi 				#printing the character inside rsi
	pushq %rdi 
	movq $1, %rdi  
	movq $1, %rdx 
	syscall
	popq %rdi 
	incq %rdi
	jmp loop

print_si:

	cmpq $0, %r12 				#if it's smaller than 0 we also need to print a minus before the number
	jl print_si_minus
	jmp string_convert

print_si_minus:
	
	movq $1, %rax 				#printing the minus
	movq $minus, %rsi 
	movq $1, %rdx 
	pushq %rdi 
	movq $1, %rdi
	syscall
	popq %rdi 
	neg %r12 					#flipping the bits in order to get the positive number
	jmp string_convert

string_convert:
	incq %r15
	movq %r12, %rax				#we take every digit of the number and cornvert it into ASCII
	pushq %r15
	movq $auxiliar_end, %r15	#r15 - address of the ASCII array's end
	loop_convert:				#the ASCII code will be stored into a 0-initialisez array
		decq %r15				#we substract to see where the number will start inside the array
		movq $0, %rdx 		
		movq $10, %r10 
		divq %r10
		addq $48, %rdx
		movb %dl, (%r15) 		

		cmpq $0, %rax 			#if the extent will be 0 then we have finished converting
		jnz loop_convert		#otherwise we convert again

	movq $auxiliar_end, %rdx
	subq %r15, %rdx				#we calculate the length of the number string 

	movq $1, %rax
	pushq %rdi 
	movq $1, %rdi
	movq %r15, %rsi

	syscall 					#we print the formated number
	popq %rdi 
	popq %r15
	incq %rdi
	jmp loop
	#ret

print_str:
	incq %r15 					#for each new formating it means that we have parsed throught a new input so we increase the 
	xor %r9, %r9
	pushq %r12

loop_count:
	incq %r9 					#calculating the length of the string that will be printed
	addq $1, %r12				#for every letter found we will increase the total by 1
	cmpb $0, (%r12)
	jne loop_count

	xor %r12, %r12				
	popq %r12
	pushq %rdi 
	movq $1, %rdi 				#printing the string
	movq $1, %rax
	leaq (%r12), %rsi 
	movq %r9, %rdx
	syscall 
	popq %rdi 
	incq %rdi
	jmp loop

print_per:

	movq $1, %rax 				#just print a percentage sign
	movq $percentage, %rsi 
	pushq %rdi  
	movq $1, %rdi 	
	movq $1, %rdx 
	syscall 
	popq %rdi
	incq %rdi
	jmp loop


exit_print:
	
	movq %rbp, %rsp 			#prologue
	popq %rbp

	ret

 	






