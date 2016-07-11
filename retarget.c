#include <stdio.h>
#include <rt_misc.h>

#pragma import(__use_no_semihosting_swi)

void dcc_put_ch(char ch)
{
    register unsigned int k;
	//printf("dcc_put_ch\n");


    do /* Wait for Terminal Ready */
    {
        __asm
        {
            MRC p14, 0, k, c0, c1;
        }
    } while (k & 0x20000000);

    __asm
    {
        MCR p14, 0, ch, c0, c5
    }
}

char dcc_get_ch(void)
{
    register unsigned int k, ch;
	//printf("dcc_get_ch\n");

    /* check only once for input byte */
    __asm
    {
        MRC p14, 0, k, c0, c1;
    }

    if (!(k & 0x40000000))
    {
        return 0;
    }
    __asm
    {
        MRC p14, 0, ch, c0, c5;
    }

    return ch;
}

int fputc(int ch, FILE *f)
{
	//printf("fputc\n");

	dcc_put_ch(ch);
    if( ch== '\n' )
    {
        dcc_put_ch('\r');
    }
	return (ch);
}

int fgetc(FILE *f)
{
	//printf("fgetc\n");
	return dcc_get_ch();
}

int ferror(FILE *f)
{
	//printf("ferror\n");
	/* Your implementation of ferror */
	return EOF;
}
