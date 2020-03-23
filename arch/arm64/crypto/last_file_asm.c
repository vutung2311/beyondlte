__attribute__ ((section(".rodata"), used))
const unsigned char last_crypto_asm_rodata = 0x20;

__attribute__ ((section(".text"), used))
void last_crypto_asm_text(void){}

__attribute__ ((section(".init.text"), used))
void last_crypto_asm_init(void){}
