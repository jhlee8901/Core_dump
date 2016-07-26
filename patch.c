

#define MEM_TST_BIT32(bitmap, offset)       (!!((bitmap) & (1 << (offset))))

uint32_t dbg_read_debug_register(uint32_t core, uint32_t reg_num)
{
    // read the value of the debug register reg_num at address reg_num << 2
    volatile uint32_t val;
    val = *((uint32_t *)(csight_addr[core] + (reg_num << 2)));
    return val;
}

void dbg_execute_arm_instruction(uint32_t core, uint32_t instr)
{
    uint32_t dbgdscr;

    // Poll DBGDSCR until InstrCompl_l is set.
    do
    {
        dbgdscr = dbg_read_debug_register(core, DBGDSCR_REG);
    }
    while  (! MEM_TST_BIT32(dbgdscr, INSTR_CMPL_BIT) );

    // Write the opcode to the DBGITR.
    dbg_write_debug_register(core, DBGITR_REG, instr);

    // Poll DBGDSCR until InstrCompl is set.
    do
    {
        dbgdscr = dbg_read_debug_register(core, DBGDSCR_REG);
    } while (! MEM_TST_BIT32(dbgdscr, INSTR_CMPL_BIT) );
 }

uint32_t dbg_read_data_com_chan(uint32_t core)
{
    uint32_t dbgdscr;
    uint32_t dtr_val;

    // Step 1. Poll DBGDSCR until TXfull is set to 1.
    do
    {
        dbgdscr = dbg_read_debug_register(core, DBGDSCR_REG);
    } while (!MEM_TST_BIT32(dbgdscr, TXFULL_BIT));

    // Read the value from DBGDTRTX.
    dtr_val = dbg_read_debug_register(core, DBGDTRTX_REG);

    return dtr_val;
}

uint32_t dbg_read_arm_register(uint32_t core, uint32_t reg)
{
    uint32_t reg_val;

    // Execute instruction MCR p14, 0, Rd, c0, c5, 0 through the DBGITR.
    dbg_execute_arm_instruction(core, 0xEE000E15 + (reg << 12));

    // Read the register value through DBGDTRTX.
    reg_val = dbg_read_data_com_chan(core);
    return reg_val;
}
