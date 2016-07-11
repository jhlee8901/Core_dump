#include <stdio.h>
#include <string.h>


/* Define & Global */

/*
typedef struct _Register{
unsigned short cpsr_flag, spsr_flag;
unsigned int general_register[12];
unsigned int cpsr, spsr;
}Regist;

Regist reg_val;
*/

#define SRAM_SRC 0x00001600 //SRAM source address
#define SRAM_DST 0x00011600 //SRAM dump address
#define SRAM_SIZE 64		//SRAM size 64KB


#define TCM_SRC 0x00022000	//TCM source address
#define TCM_DST 0x00023000	//TCM dump address
#define TCM_SIZE 4			//TCM size 4KB


#define REG_BASE_ADDR 0x00001000 //Base address

extern void Dump_Regist(unsigned int reg_base_addr);




/* EXCEPTION Generate CODE */

void(*funcP)(void);

#pragma push
#pragma O0
typedef void(*_func_t)(void);
static void undef(void)
{
	static const int instr = 0xffffffff;
	(*((_func_t)&instr))();
}

static void data_abort(void)
{
	static int * null_p = (int *)0x1;
	int temp;
	temp = *null_p;
}

static void prefetch_abort(void)
{
	_func_t foo;
	foo = (_func_t)(0xffffffff);
	(*foo)();
}
#pragma pop


/* SRAM Memory dump code */

static int Dump_SRAM()
{
	unsigned char ret = 0;
	unsigned const char* SRAM_src_addr = SRAM_SRC;
	unsigned char* SRAM_dst_addr = SRAM_DST;
	
	//dump
	memcpy(SRAM_dst_addr, SRAM_src_addr, SRAM_SIZE * 1024);
	
	//check
	ret = memcmp(SRAM_src_addr, SRAM_dst_addr, SRAM_SIZE * 1024); // 0 equal 

	return ret;
}

/* TCM Memory dump code */

static int Dump_TCM()
{
	unsigned char ret = 0;
	unsigned const char* TCM_src_addr = TCM_SRC;
	unsigned char* TCM_dst_addr = TCM_DST;
	
	//dump
	memcpy(TCM_dst_addr, TCM_src_addr, TCM_SIZE*1024);
	
	//check
	ret = memcmp(TCM_src_addr, TCM_dst_addr, TCM_SIZE * 1024); // 0 equal 
	
	return ret;
}


/* memory input test */

static void Input_Test()
{
	unsigned int* sram_base_addr = SRAM_SRC;
	unsigned int* tcm_base_addr = TCM_SRC;

	int len,i;

	len = SRAM_SIZE * 1024 / 4;

	for (i = 0; i < len; i++){
		*sram_base_addr++ = i;
	}

	len = TCM_SIZE * 1024 / 4;

	for (i = 0; i < len; i++){
		*tcm_base_addr++ = i;
	}
}



void main(void)
{
	//int *bad = NULL;
	


	// input test
	Input_Test();


	// UNDEFINED exception TEST 1
	undef();

	

	// DATA ABORT exception TEST 1

	// a = *bad; // exception 안남	



	// DATA ABORT exception TEST 2
	
	//data_abort();



	// PREFETCH ABORT exception TEST 1
	
	//prefetch_abort();



	// PREFETCH ABORT exception TEST 1

	//funcP = (void(*)(void)) 0x00000001; //======> prefetch 안되고 undefined 로 빠짐	
	//funcP();
		
	

	//Dump_memory(0x0,4096);
	
	//printf("Dump Register\n");
	//Dump_Regist(base_addr);

	printf("No!!!!\n");

	while(1)
	{
		printf("hello world\n");
		//*bad = 0xffff;
	}
	
}

void __irq harm_undefined_handler_dump()
{	
	unsigned int base_addr = REG_BASE_ADDR;

	Dump_Regist(base_addr);
	printf("[OK] Register\n");

	if (!Dump_SRAM()){
		printf("[OK] SRAM\n");
	}
		
	if (!Dump_TCM()){
		printf("[OK] TCM\n");
	}

	printf("UNDEFINED!\n");	
	for (;;);
}

void __irq harm_abort_handler_dump()
{
	//
	printf("DATA ABORT!\n");
	for (;;);
}

void __irq harm_prefetch_handler_dump()
{
	//
	printf("PREFETCH ABORT!\n");
	for (;;);
}

