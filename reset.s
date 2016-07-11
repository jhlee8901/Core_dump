

	PRESERVE8

	AREA reset, CODE


	; --------------------------------------------------------------------
	; Define
	; --------------------------------------------------------------------
MODE_USR        EQU 0x10
MODE_FIQ        EQU 0x11
MODE_IRQ        EQU 0x12
MODE_SVC        EQU 0x13
MODE_ABT        EQU 0x17
MODE_UND        EQU 0x1B
MODE_SYS        EQU 0x1F

I_BIT           EQU 0x80
F_BIT           EQU 0x40
A_BIT           EQU 0xFFFFFEFF

DTCM_ON         EQU 0x04


	; --------------------------------------------------------------------
	; Import
	; --------------------------------------------------------------------
        IMPORT  |Image$$CPU_STACK_SVC$$ZI$$Limit|
        IMPORT  |Image$$CPU_STACK_SYS$$ZI$$Limit|
        IMPORT  |Image$$CPU_STACK_ABT$$ZI$$Limit|
        ;IMPORT  |Image$$CPU_STACK_UND$$ZI$$Limit|
        IMPORT  |Image$$CPU_STACK_IRQ$$ZI$$Limit|
        IMPORT  |Image$$CPU_STACK_FIQ$$ZI$$Limit|

        IMPORT  __main

		IMPORT harm_abort_handler_dump
		IMPORT harm_undefined_handler_dump
		IMPORT harm_prefetch_handler_dump
		


	; --------------------------------------------------------------------
	; Export
	; --------------------------------------------------------------------
	EXPORT  harm_reset_handler
	EXPORT  harm_undefined_handler
	EXPORT  harm_swi_handler
	EXPORT  harm_prefetch_handler
	EXPORT  harm_abort_handler
	;EXPORT  harm_undefined_handler
	EXPORT  harm_irq_handler
	EXPORT  harm_fiq_handler

	

harm_reset_handler
	; --------------------------------------------------------------------
	; tries to access registers
	; will be removed
	; --------------------------------------------------------------------
	mov  r0, #0x0
	mov  r1, #0x0
	mov  r2, #0x0
	mov  r3, #0x0
	mov  r4, #0x0
	mov  r5, #0x0
	mov  r6, #0x0
	mov  r7, #0x0
	mov  r8, #0x0
	mov  r9, #0x0
	mov r10, #0x0
	mov r11, #0x0
	mov r12, #0x0


	; --------------------------------------------------------------------
	; Switch to User/System (SYS) mode and Initialize
	; --------------------------------------------------------------------
	MSR CPSR_c, #MODE_SYS:OR:I_BIT:OR:F_BIT ; No interrupts
	LDR sp, =|Image$$CPU_STACK_SYS$$ZI$$Limit|
	; --------------------------------------------------------------------
	; Switch to Fast Interrupt (FIQ) mode and Initialize
	; --------------------------------------------------------------------
	MSR CPSR_c, #MODE_FIQ:OR:I_BIT:OR:F_BIT ; No interrupts
	LDR sp, =|Image$$CPU_STACK_FIQ$$ZI$$Limit|
	; --------------------------------------------------------------------
	; Switch to Interrupt (IRQ) mode and Initialize
	; --------------------------------------------------------------------
	MSR CPSR_c, #MODE_IRQ:OR:I_BIT:OR:F_BIT ; No interrupts
	LDR sp, =|Image$$CPU_STACK_IRQ$$ZI$$Limit|
	; --------------------------------------------------------------------
	; Switch to Abort (ABT) mode and Initialize
	; --------------------------------------------------------------------
	MSR CPSR_c, #MODE_ABT:OR:I_BIT:OR:F_BIT ; No interrupts
	LDR sp, =|Image$$CPU_STACK_ABT$$ZI$$Limit|
	; --------------------------------------------------------------------
	; Switch to Undefined Exception (UND) mode and Initialize
	; --------------------------------------------------------------------
	;MSR CPSR_c, #MODE_UND:OR:I_BIT:OR:F_BIT ; No interrupts
	;LDR sp, =|Image$$CPU_STACK_UND$$ZI$$Limit|
	; --------------------------------------------------------------------
	; Switch to SVC mode and Finish the Setup
	; --------------------------------------------------------------------
	MSR CPSR_c, #MODE_SVC:OR:I_BIT:OR:F_BIT ; No interrupts
	LDR sp, =|Image$$CPU_STACK_SVC$$ZI$$Limit|


	; --------------------------------------------------------------------
	; ITCM base address 0x00800000, size = 64K, enabled = true
	; --------------------------------------------------------------------
	;LDR     r0, =0x21
	;LDR     r0, =0x00800021
	LDR     r0, =0x0000001D
	; --------------------------------------------------------------------
	; write instruction TCM (ATCM) region register
	; --------------------------------------------------------------------
	MCR     p15,  0, r0, c9, c1, 1
	; --------------------------------------------------------------------
	; DTCM base address 0x00000000, size = 64K, enabled = true
	; --------------------------------------------------------------------
	;LDR     r0, =0x400019
	;LDR     r0, =0x19
	LDR     r0, =0x00C0001D
	; --------------------------------------------------------------------
	; write data TCM (BTCM) region register
	; --------------------------------------------------------------------
	MCR     p15,  0, r0, c9, c1, 0

	; ---------------------------------------------------------------------
	; Push Registers to Stack to prevent corruption
	; will be removed
	; ---------------------------------------------------------------------
	;STMFD   SP!, {r0-r1,lr}


	; ---------------------------------------------------------------------
	; jump to main function
	; will be removed
	; ---------------------------------------------------------------------
	B __main

    ;; Disable MPU before reconfiguring it
        MRC p15, 0, R1, c1, c0, 0   ; read CP15 register 1
        BIC R1, R1, #0x1
        DSB
        MCR p15, 0, R1, c1, c0, 0   ; disable MPU - Now running on default Cortex R5 memory map
        ISB
 ;; set MPU Region 0,  8MB, 0x0000_0000 - 0x007F_FFFF, NORMAL MEMORY     , NON CACHEABLE, NON SHAREABLE ( R5 ATCM )
        MOV     r0, #0x0
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x00000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x0000002D  ; size[5:1]=10_110 (8MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region 1,  4MB, 0x0080_0000 - 0x00BF_FFFF, STRONGLY-ORDERED , NON CACHEABLE, NON SHAREABLE ( R5 B TCM )
        MOV     r0, #0x1
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x00800000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x0000002B  ; size[5:1]=10_110 (4MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000300  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=000, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region 2,  4MB, 0x00C0_0000 - 0x00FF_FFFF, NORMAL MEMORY    , NON CACHEABLE, NON SHAREABLE ( R5 B TCM )
        MOV     r0, #0x2
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x00C00000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x0000002B  ; size[5:1]=10_101 (4MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4

 ;; set MPU Region 3, 32MB, 0x0200_0000 - 0x03FF_FFFF, NORMAL MEMORY    , NON CACHEABLE, NON SHAREABLE ( R5 SLAVE IF )
        MOV     r0, #0x3
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x02000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000031  ; size[5:1]=11_000 (32MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region 4, 64MB, 0x0400_0000 - 0x07FF_FFFF, DEVICE TYPE       , NON CACHEABLE, NON SHAREABLE (R5 LLPP)
        MOV     r0, #0x4
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x04000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000033  ; size[5:1]=11_010 (68MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000310  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=010, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4

 ;; set MPU Region 5, 32MB, 0x0800_0000 - 0x09FF_FFFF, DEVICE TYPE       , NON CACHEABLE, NON SHAREABLE (R5 LLPP)
        MOV     r0, #0x5
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x08000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000031  ; size[5:1]=11_010 (32MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000310  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=010, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region 6, 32MB, 0x0A00_0000 - 0x0BFF_FFFF, NORMAL MEMORY     , NON CACHEABLE, NON SHAREABLE (R5 LLPP)
        MOV     r0, #0x6
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x0A000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000031  ; size[5:1]=11_010 (32MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4

 ;; set MPU Region 7, 256MB, 0x1000_0000 - 0x1FFF_FFFF, DEVICE TYPE      , NON CACHEABLE, NON SHAREABLE (PERI)
        MOV     r0, #0x7
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x10000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000037  ; size[5:1]=11_011 (256MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000310  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=010, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4

 ;; set MPU Region 8,   2GB, 0x4000_0000 - 0xBFFF_FFFF, NORMAL MEMORY    , NON CACHEABLE, NON SHAREABLE (DDR)
        MOV     r0, #0x8
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0x40000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x0000003D  ; size[5:1]=11_110 (2GB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0  ; non cachable
        ;   LDR     r3, =0x00000329  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=101, S[2]=0, C[1]=0, B[0]=1 ; Cachable
     MCR     p15, 0, r3, c6, c1, 4

 ;; set MPU Region 9, 256MB, 0xC000_0000 - 0xCFFF_FFFF, DEVICE TYPE      , NON CACHEABLE, NON SHAREABLE ( PE )
        MOV     r0, #0x9
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0xC0000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000037  ; size[5:1]=11_011 (256MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000310  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=010, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region A, 1MB, 0xD000_0000 - 0xD00F_FFFF, NORMAL MEMORY      ,    CACHEABLE(Write Allocate), NON SHAREABLE ( CBM )
        MOV     r0, #0xA
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0xD0000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000027  ; size[5:1]=10_011 (1MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000329  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=101, S[2]=0, C[1]=0, B[0]=1
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region B, 128KB, 0xDC00_0000 - 0xDC01_FFFF, NORMAL MEMORY    ,  NON CACHEABLE, NON SHAREABLE ( DBM )
        MOV     r0, #0xB
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0xDC000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x0000002D  ; size[5:1]=10_110 (128KB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4
 ;; set MPU Region C, 128KB, 0xDC10_0000 - 0xDC9F_FFFF, NORMAL MEMORY    ,  NON CACHEABLE, NON SHAREABLE ( CXE )
        MOV     r0, #0xC
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0xD0000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000037  ; size[5:1]=11_011 (256MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4

 ;; set MPU Region D, 512MB, 0xE000_0000 - 0xFFFF_FFFF, NORMAL MEMORY    , NON CACHEABLE, NON SHAREABLE ( ROM )
        MOV     r0, #0xD
        MCR     p15, 0, r0, c6, c2, 0
        LDR     r1, =0xE0000000  ; base address
        MCR     p15, 0, r1, c6, c1, 0
        LDR     r2, =0x00000039  ; size[5:1]=11_100 (512MB), Enable[0]=1
        MCR     p15, 0, r2, c6, c1, 2
        LDR     r3, =0x00000308  ; XN[12]=0, AP[10:8]=011, TEX[5:3]=001, S[2]=0, C[1]=0, B[0]=0
        MCR     p15, 0, r3, c6, c1, 4

 ;;set System Control Reg to enable MPU
     MRC     p15, 0, r1, c1, c0, 0
     ORR     r1, r1, #0x1
     DSB
     MCR     p15, 0, r1, c1, c0, 0

;     ISB


;	; ---------------------------------------------------------------------
;	; Invalidate caches, Disable the MPU and caches (reboot case)
;	; ---------------------------------------------------------------------
;        MCR     p15,  0, r0, c15, c5, 0               ; Invalidate the data cache (dcache)
;        MCR     p15,  0, r0,  c7, c5, 0               ; Invalidate the instruction cache (icache)
;        MRC     p15,  0, r0,  c1, c0, 0               ; Read System Control Register (CP15)
;        BIC      r0, r0, #0x1                         ; Disable the MPU
;        BIC      r0, r0, #0x4                         ; Disable the data cache (dcache)
;        BIC      r0, r0, #0x1000                      ; Disable the instruction cache (icache)
;        DSB
;        MCR     p15,  0, r0,  c1, c0, 0               ; Write System Control Register (CP15)
;        ISB
;        MRC     p15,  0, r0,  c1, c0, 0               ; Read System Control Register (CP15)
;
;
;	; ---------------------------------------------------------------------
;	; REGION 0:
;	;   + B0-TCM Area
;	;   + Normal, Instruction fetch, Full access, Non-shareable memory
;	; ---------------------------------------------------------------------
;	; ---------------------------------------------------------------------
;	; Set the region number
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x0                             ; Load region number into r0
;        MCR     p15,  0, r0,  c6, c2, 0               ; Write CP15 Memory Region Register to set region Number
;	; ---------------------------------------------------------------------
;	; Set the base address
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x00000000                      ; Load Region Base Address into r0
;        MCR     p15,  0, r0,  c6, c1, 0               ; Write Region Base Address Register
;	; ---------------------------------------------------------------------
;	; Set up the Region Access Permissions
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Full Access
;        LDR      r1, =0x08
;        ORR      r0, r1, r0, LSL #8
;        BIC      r0, r0, #0x1000                      ; Enable Execute Permissions
;        MCR      p15, 0, r0,  c6, c1, 4               ; Write Region Access Control Register
;	; ---------------------------------------------------------------------
;	; Set the region size and enable the region
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x0E
;        LDR      r1, =0x01
;        ORR      r0, r1, r0, LSL #1
;        DSB
;        MCR     p15,  0, r0,  c6, c1, 2               ; Write Region Size and Enable Register
;        ISB
;	; ---------------------------------------------------------------------
;
;
;	; ---------------------------------------------------------------------
;	; REGION 1:
;	;   + B1-TCM Area
;	;   + Normal, No Instruction fetch, Full access, Non-shareable memory
;	; ---------------------------------------------------------------------
;	; ---------------------------------------------------------------------
;	; Set the region number
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x1                             ; Load region number into r0
;        MCR     p15,  0, r0,  c6, c2, 0               ; Write CP15 Memory Region Register to set region Number
;	; ---------------------------------------------------------------------
;	; Set the base address
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x00400000                      ; Load Region Base Address into r0
;        MCR     p15,  0, r0,  c6, c1, 0               ; Write Region Base Address Register
;	; ---------------------------------------------------------------------
;	; Set up the Region Access Permissions
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Full Access
;        LDR      r1, =0x08
;        ORR      r0, r1, r0, LSL #8
;        ORR      r0, r0, #0x1000                      ; Disable Execute Permissions
;        MCR      p15, 0, r0,  c6, c1, 4               ; Write Region Access Control Register
;	; ---------------------------------------------------------------------
;	; Set the region size and enable the region
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x0F
;        LDR      r1, =0x01
;        ORR      r0, r1, r0, LSL #1
;        DSB
;        MCR     p15,  0, r0,  c6, c1, 2               ; Write Region Size and Enable Register
;        ISB
;	; ---------------------------------------------------------------------
;
;
;	; ---------------------------------------------------------------------
;	; REGION 2:
;	;   + A-TCM Area
;	;   + Normal, Instruction fetch, Full access, Non-shareable memory
;	; ---------------------------------------------------------------------
;	; ---------------------------------------------------------------------
;	; Set the region number
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x2                             ; Load region number into r0
;        MCR     p15,  0, r0,  c6, c2, 0               ; Write CP15 Memory Region Register to set region Number
;	; ---------------------------------------------------------------------
;	; Set the base address
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x00800000                      ; Load Region Base Address into r0
;        MCR     p15,  0, r0,  c6, c1, 0               ; Write Region Base Address Register
;	; ---------------------------------------------------------------------
;	; Set up the Region Access Permissions
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Full Access
;        LDR      r1, =0x08
;        ORR      r0, r1, r0, LSL #8
;        BIC      r0, r0, #0x1000                      ; Enable Execute Permissions
;        MCR      p15, 0, r0,  c6, c1, 4               ; Write Region Access Control Register
;	; ---------------------------------------------------------------------
;	; Set the region size and enable the region
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x10
;        LDR      r1, =0x01
;        ;LDR     r1,  =0x05                            ; size: 256K
;        ORR      r0, r1, r0, LSL #1
;        DSB
;        MCR     p15,  0, r0,  c6, c1, 2               ; Write Region Size and Enable Register
;        ISB
;	; ---------------------------------------------------------------------
;
;
;	; ---------------------------------------------------------------------
;	; REGION 3:
;	;   + Register Area
;	;   + Device, No instruction fetch, full access, shareable memory
;	; ---------------------------------------------------------------------
;	; ---------------------------------------------------------------------
;	; Set the region number
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Load region number into r0
;        MCR     p15,  0, r0,  c6, c2, 0               ; Write CP15 Memory Region Register to set region Number
;	; ---------------------------------------------------------------------
;	; Set the base address
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x80000000                      ; Load Region Base Address into r0
;        MCR     p15,  0, r0,  c6, c1, 0               ; Write Region Base Address Register
;	; ---------------------------------------------------------------------
;	; Set up the Region Access Permissions
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Full Access
;        LDR      r1, =0x08
;        ORR      r0, r1, r0, LSL #8
;        ORR      r0, r0, #0x1000                      ; Disable Execute Permissions
;        MCR      p15, 0, r0,  c6, c1, 4               ; Write Region Access Control Register
;	; ---------------------------------------------------------------------
;	; Set the region size and enable the region
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x1C
;        LDR      r1, =0x01
;        ORR      r0, r1, r0, LSL #1
;        DSB
;        MCR     p15,  0, r0,  c6, c1, 2               ; Write Region Size and Enable Register
;        ISB
;	; ---------------------------------------------------------------------
;
;
;	; ---------------------------------------------------------------------
;	; REGION 4:
;	;   + CBM Raw SRAM Area
;	;   + Normal, No Instruction fetch, Full access, Non-shareable memory
;	; ---------------------------------------------------------------------
;	; ---------------------------------------------------------------------
;	; Set the region number
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x4                             ; Load region number into r0
;        MCR     p15,  0, r0,  c6, c2, 0               ; Write CP15 Memory Region Register to set region Number
;	; ---------------------------------------------------------------------
;	; Set the base address
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x90000000                      ; Load Region Base Address into r0
;        MCR     p15,  0, r0,  c6, c1, 0               ; Write Region Base Address Register
;	; ---------------------------------------------------------------------
;	; Set up the Region Access Permissions
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Full Access
;        LDR      r1, =0x08
;        ORR      r0, r1, r0, LSL #8
;        BIC      r0, r0, #0x1000                      ; @todo: Set back to -> Disable Execute Permissions
;        MCR      p15, 0, r0,  c6, c1, 4               ; Write Region Access Control Register
;	; ---------------------------------------------------------------------
;	; Set the region size and enable the region
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x13
;        LDR      r1, =0x01
;        ORR      r0, r1, r0, LSL #1
;        DSB
;        MCR     p15,  0, r0,  c6, c1, 2               ; Write Region Size and Enable Register
;        ISB
;	; ---------------------------------------------------------------------
;
;
;	; ---------------------------------------------------------------------
;	; REGION 5:
;	;   + DRAM Area
;	;   + Normal, WriteThrough Cacheable, Instruction fetch, Full access, Shareable memory
;	; ---------------------------------------------------------------------
;	; ---------------------------------------------------------------------
;	; Set the region number
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x5                             ; Load region number into r0
;        MCR     p15,  0, r0,  c6, c2, 0               ; Write CP15 Memory Region Register to set region Number
;	; ---------------------------------------------------------------------
;	; Set the base address
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x40000000                      ; Load Region Base Address into r0
;        MCR     p15,  0, r0,  c6, c1, 0               ; Write Region Base Address Register
;	; ---------------------------------------------------------------------
;	; Set up the Region Access Permissions
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x3                             ; Full Access
;        LDR      r1, =0x08
;        ORR      r0, r1, r0, LSL #8
;        BIC      r0, r0, #0x1000                      ; Enable Execute Permissions
;        MCR      p15, 0, r0,  c6, c1, 4               ; Write Region Access Control Register
;	; ---------------------------------------------------------------------
;	; Set the region size and enable the region
;	; ---------------------------------------------------------------------
;        LDR      r0, =0x1D
;        LDR      r1, =0x01
;        ORR      r0, r1, r0, LSL #1
;        DSB
;        MCR     p15,  0, r0,  c6, c1, 2               ; Write Region Size and Enable Register
;        ISB
;	; ---------------------------------------------------------------------
;
;
;	; ---------------------------------------------------------------------
;	; Enable the MPU
;	; can be enable after each region size of MPU fixed
;	; ---------------------------------------------------------------------
;        ;MRC     p15,  0, r0,  c1, c0, 0               ; Read CP15 register 1
;        ;ORR      r0, r0, #0x1                         ; Set MPU bit
;        ;ORR      r0, r0, #0x4                         ; Set Data Cache Bit
;        ;ORR      r0, r0, #0x1000                      ; Set Instruction Cache
;        ;DSB                                           ; Flush data pipeline
;        ;MCR     p15,  0, r0,  c1, c0, 0               ; Enable MPU, I cache and D cache
;        ;ISB                                           ; Flush instruction pipeline
;        ;MRC     p15,  0, r0,  c1, c0, 0               ; Read CP15 register 1
;
;
;	; ---------------------------------------------------------------------
;	; Pop Registers to Stack to prevent corruption
;	; will be removed
;	; ---------------------------------------------------------------------
;        ;LDMFD   sp!, {r0-r1,lr}                       ; Pop registers to preserve context
;        ;BX      lr


	; ---------------------------------------------------------------------
	; switch ARM mode to user
	; will be removed
	; ---------------------------------------------------------------------
	;msr cpsr_c, #MODE_USR


	; ---------------------------------------------------------------------
	; jump to main function
	; ---------------------------------------------------------------------
	B __main





harm_undefined_handler
	;B harm_undefined_handler
	B harm_undefined_handler_dump

harm_swi_handler
	B harm_swi_handler

harm_prefetch_handler
	;B harm_prefetch_handler
	B harm_prefetch_handler_dump

harm_abort_handler
	;B harm_abort_handler
	B harm_abort_handler_dump

;harm_undefined_handler
;	B harm_undefined_handler

harm_irq_handler
	B harm_irq_handler

harm_fiq_handler
	B harm_fiq_handler


	END
