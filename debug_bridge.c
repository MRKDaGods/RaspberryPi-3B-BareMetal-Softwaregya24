void printf(char *fmt, ...)
{
}

void LOLXDD()
{
}

void LOLX()
{
}

void Error(int where)
{
    printf("Error at: %d\n", where);
}

void ASMDBG(int step)
{
    printf("Assembly Step [%d]\n", step);
}

void PrintInt(unsigned int value)
{
    printf("Value: 0x%x\n", value);
}

void PrintLong(unsigned long value)
{
    printf("LValue: 0x%x\n", value);
}

void PrintChar(char c)
{
    printf("C: %c\n", c);
}

void PrintBuffer(unsigned int *buf, int size)
{
    for (int i = 0; i < size; i++)
    {
        printf("[%d] Value: 0x%x\n", buf[i]);
    }
}
