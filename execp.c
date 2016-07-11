#pragma push
#pragma O0
typedef void (*_func_t)(void);
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

#pragma pop

