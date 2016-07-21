#include <stdio.h>
#include <string.h>


/* Define Macro */

#define SRAM_SRC 0x00001600		//SRAM source address
#define SRAM_DST 0x00011600		//SRAM dump address
#define SRAM_SIZE 64			//SRAM size 64KB


#define TCM_SRC 0x00022000		//TCM source address
#define TCM_DST 0x00023000		//TCM dump address
#define TCM_SIZE 4				//TCM size 4KB


//#define REG_BASE_ADDR 0x00001000 //Base address



/* Registers Dump */

//unsigned int base_addr = REG_BASE_ADDR; // Register dirt 문제를 막기 위해 전역으로 빼버림

extern void Dump_Regist(void);
//extern void Dump_Regist(unsigned int reg_base_addr);
//extern void Dump_Regist_Push();



/* EXCEPTION Generate Code */

typedef void(*_func_t)(void);

static void undef(void)
{
	static const int instr = 0xffffffff;
	(*((_func_t)&instr))();
}

static void data_abort(void)
{
	static int * null_p = (int *)0x12345678;
	int temp;
	temp = *null_p;
}

static void prefetch_abort(void)
{
	_func_t foo;
	foo = (_func_t)(0xffffffff);
	(*foo)();
}


/* SRAM Memory Dump */

static int Dump_SRAM()
{
	unsigned char ret;
	unsigned const char* SRAM_src_addr = SRAM_SRC;
	unsigned char* SRAM_dst_addr = SRAM_DST;

	//dump
	memcpy(SRAM_dst_addr, SRAM_src_addr, SRAM_SIZE * 1024);

	//check
	ret = memcmp(SRAM_src_addr, SRAM_dst_addr, SRAM_SIZE * 1024);

	return ret;
}



/* TCM Memory Dump */

static int Dump_TCM()
{
	unsigned char ret;
	unsigned const char* TCM_src_addr = TCM_SRC;
	unsigned char* TCM_dst_addr = TCM_DST;

	//dump
	memcpy(TCM_dst_addr, TCM_src_addr, TCM_SIZE * 1024);

	//check
	ret = memcmp(TCM_src_addr, TCM_dst_addr, TCM_SIZE * 1024);

	return ret;
}



/* Write Data for dump test */

static void Input_Test()
{
	unsigned int* sram_base_addr = SRAM_SRC;
	unsigned int* tcm_base_addr = TCM_SRC;

	int len, i;

	len = SRAM_SIZE * 1024 / 4;

	for (i = 0; i < len; i++){
		*sram_base_addr++ = i;
	}

	len = TCM_SIZE * 1024 / 4;

	for (i = 0; i < len; i++){
		*tcm_base_addr++ = i;
	}
}



/* main */

void main(void)
{

	// write data

	Input_Test();


	// UNDEF Exception TEST

	undef();


	// DATA ABORT Exception TEST

	//data_abort();


	// PREFETCH ABORT Exception TEST

	//prefetch_abort();


	while (1)
	{
		printf("hello world\n");
	}

}



/* ABORT(data) Exception handler */

void __irq harm_abort_handler_dump()
{
	//unsigned int base_addr = REG_BASE_ADDR;

	//Dump_Regist(base_addr);
	Dump_Regist();

	printf("[OK] Register\n");

	if (!Dump_SRAM()){
		printf("[OK] SRAM\n");
	}

	if (!Dump_TCM()){
		printf("[OK] TCM\n");
	}

	printf("DATA ABORT!\n");
	for (;;);
}



/* UNDEF Exception handler */

void __irq harm_undefined_handler_dump()
{
	//실질적인 Register dump 는 이 부분에서 끝내야 한다

	//unsigned int base_addr = REG_BASE_ADDR; // R4 가 덮어씌워짐

	//Dump_Regist_Push();
	//Dump_Regist(base_addr); // parameter로 인해서 R0 가 덮어씌워짐
	Dump_Regist();

	printf("[OK] Register\n");

	if (!Dump_SRAM()){
		printf("[OK] SRAM\n");
	}

	if (!Dump_TCM()){
		printf("[OK] TCM\n");
	}

	printf("UNDEF!\n");


	for (;;);
}



/* ABORT(prefetch) Exception handler */

void __irq harm_prefetch_handler_dump()
{
	//unsigned int base_addr = REG_BASE_ADDR;

	//Dump_Regist(base_addr);
	Dump_Regist();

	printf("[OK] Register\n");

	if (!Dump_SRAM()){
		printf("[OK] SRAM\n");
	}

	if (!Dump_TCM()){
		printf("[OK] TCM\n");
	}

	printf("PREFETCH ABORT!\n");
	for (;;);
}

