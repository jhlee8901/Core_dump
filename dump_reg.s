
	PRESERVE8

	AREA dump_reg, CODE, READONLY


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			define
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

REG_BASE_ADDR			EQU	0x1000	; Base_Address

MODE_USR				EQU 0x10
MODE_FIQ				EQU 0x11
MODE_IRQ				EQU 0x12
MODE_SVC				EQU 0x13
MODE_ABT				EQU 0x17
MODE_UND				EQU 0x1B
MODE_SYS				EQU 0x1F



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			EXPORT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	EXPORT	Dump_Regist



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		DUMP all Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Dump_Regist


;;;; General registers, CPSR, Current Exception Registers(r13, r14, SPSR) Dump
	

	;; save r0 and set the base address
	push {r0}						; push original r0 (base addr 를 위해 R0를 stack에 저장)
	LDR r0, =REG_BASE_ADDR			; mov 명령어는 상수가 0~255 8bit 만큼만 가능하기에 LDR을 사용



	
	STMIA r0!, {r0 - r15}			; Dump r0 ~ r15 (r13_exception,14_exception)
	
	mrs	r7, cpsr
	STR r7,[r0]						; Dump cpsr

	mrs	r7, spsr
	STR r7,[r0,#0x4]				; Dump spsr of current Exception



	;; restore r0
	pop {r1}						; pop original r0
	LDR r2, =REG_BASE_ADDR
	STR r1,[r2]						; Dump r0 in stack



	

;;;; Banked Registers Dump
	
	add r0, r0, #0x10				; Row & Column configuration
	mrs r6, cpsr					; Save return mode	(Current Exception mode)

		

	;; SYS Dump
	
	mrs r7, cpsr					; 
		
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #MODE_SYS				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump SYS r13, r14

	add r0, r0, #0x8				; For Row & Column configuration
	


	;; UNDEF Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #MODE_UND				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	
	add r0, r0, #0x8				; For Row & Column configuration
	
	
	;; ABT Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #MODE_ABT				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr

	add r0, r0, #0x8				; For Row & Column configuration



	;; SVC Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #MODE_SVC				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	
	add r0, r0, #0x8				; For Row & Column configuration



	;; IRQ Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #MODE_IRQ				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r13, r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	
	add r0, r0, #0x8				; For Row & Column configuration
	
	
	
	;; FIQ Dump	
	
	bic r7, r7, #&1F				; Clear mode bits
	orr r7, r7, #MODE_FIQ				
	msr cpsr_c, r7					; Change mode
	
	STMIA r0!, {r8 - r14}			; Dump UNDEF r13, r14
	mrs	r5, spsr
	STR r5,[r0]						; Dump spsr_undef
	

	
	
;;;; return to original MODE

	msr cpsr_c, r6
	    
	mov pc,lr						; Return

    END


