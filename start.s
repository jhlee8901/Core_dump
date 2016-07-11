

	PRESERVE8

	AREA dsm_start, CODE, READONLY

	ENTRY


	; --------------------------------------------------------------------
	; Import
	; --------------------------------------------------------------------
	IMPORT harm_reset_handler
	IMPORT harm_undefined_handler
	IMPORT harm_swi_handler
	IMPORT harm_prefetch_handler
	IMPORT harm_abort_handler
	IMPORT harm_irq_handler
	IMPORT harm_fiq_handler


	; --------------------------------------------------------------------
	; Export
	; --------------------------------------------------------------------
	EXPORT vector_table


vector_table
	ldr pc, harm_reset_handler_addr
	ldr pc, harm_undefined_handler_addr
	ldr pc, harm_swi_handler_addr
	ldr pc, harm_prefetch_handler_addr
	ldr pc, harm_abort_handler_addr
	NOP
	ldr pc, harm_irq_handler_addr
	ldr pc, harm_fiq_handler_addr


harm_reset_handler_addr      DCD harm_reset_handler
harm_undefined_handler_addr  DCD harm_undefined_handler
harm_swi_handler_addr        DCD harm_swi_handler
harm_prefetch_handler_addr   DCD harm_prefetch_handler
harm_abort_handler_addr      DCD harm_abort_handler
harm_irq_handler_addr        DCD harm_irq_handler
harm_fiq_handler_addr        DCD harm_fiq_handler

	END
	
