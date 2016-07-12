
	PRESERVE8

	AREA dump_reg, CODE, READONLY

	EXPORT	Dump_Regist

	;MODE_USR         0x10
	;MODE_FIQ         0x11
	;MODE_IRQ         0x12
	;MODE_SVC         0x13
	;MODE_ABT         0x17
	;MODE_UND         0x1B
	;MODE_SYS         0x1F
	
Dump_Regist


;;;; General registers, CPSR, Current Exception Registers(r13, r14, SPSR) Dump
	
	STMIA r0!, {r0 - r15}			; Dump r0 ~ r15 (r13_exception,14_exception)
	
	mrs	r7, cpsr
	STR r7,[r0]						; Dump cpsr

	mrs	r7, spsr
	STR r7,[r0,#0x4]				; Dump spsr of current Exception





	

;;;; Banked Registers Dump
	
	add r0, r0, #0x10				; Row & Column configuration
	mrs r6, cpsr					; Save return address	(Current Exception Address)

		

	;; SYS Dump
	
	mrs r7, cpsr					; 
		
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #0x1F				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump SYS r13, r14

	add r0, r0, #0x8				; For Row & Column configuration
	


	;; UNDEF Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #0x1B				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	
	add r0, r0, #0x8				; For Row & Column configuration
	
	
	;; ABT Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #0x17				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr

	add r0, r0, #0x8				; For Row & Column configuration



	;; SVC Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #0x13				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	
	add r0, r0, #0x8				; For Row & Column configuration



	;; IRQ Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #0x12				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	
	add r0, r0, #0x8				; For Row & Column configuration
	
	
	
	;; FIQ Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #0x11				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r8 - r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	

	
	
;;;; return to original MODE

	msr cpsr_c, r6

    BX   lr							; Return

    END


