

	PRESERVE8

	AREA dump_reg, CODE, READONLY

	EXPORT	Dump_Regist

	
Dump_Regist

	;mov r1, r2						;test
	;mov r0, #0x1030				;test
	;STMIA r0!, {r0, r1, r2, r3}	;test
	;STMIA r4!, {r0 - r15}	;test


	STMIA r0!, {r0 - r15}			; Dump r0 ~ r15
		
	mrs	r7, cpsr	
	STR r7,[r0]						; Dump cpsr

	mrs	r7, spsr
	STR r7,[r0,#0x4]				; Dump cpsr

    BX   lr							; Return
    END
