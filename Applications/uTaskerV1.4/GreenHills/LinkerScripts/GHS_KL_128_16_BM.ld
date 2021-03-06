// GHS_KL_128_16_BM.ld
// Green Hills memory file for the Kinetis KL - for use with the uTasker project
// Use when running in FLASH together with a boot loader (128k FLASH / 16k CPU SRAM)

CONSTANTS {
    sram_size = 16k
    flash_size = 128K
    bootloader_size = 0x8080
    int_vect_size = 0xc0
}

MEMORY {
    ram_rsvd1   : ORIGIN = 0x20000000 - sram_size/4 + int_vect_size, LENGTH = 0
    ram_memory  : ORIGIN = .,	        LENGTH = sram_size-int_vect_size-16
    ram_rsvd2   : ORIGIN = ., 	        LENGTH = 0    

    flash_vector : ORIGIN = bootloader_size, LENGTH = 0x8
    flash_memory : ORIGIN = .,          LENGTH = flash_size-bootloader_size-8
    flash_rsvd2  : ORIGIN = .,          LENGTH = 0    
}

DEFAULTS {
    stack_reserve = 0
    heap_reserve = 2K
}

//
// Program layout for starting in ROM, copying data to RAM,
// and continuing to execute out of ROM.
//

SECTIONS
{

//
// ROM SECTIONS
//
    .vectors					        : > flash_vector
    .text				                : > flash_memory
    .syscall					        : > .
    .intercall					        : > .
    .interfunc  				        : > .

    .rodata 					        : > .
    .sdata2 					        : > .

    .secinfo 					        : > .
    .fixaddr 					        : > .
    .fixtype 					        : > .
    
    .CROM.sdata  	                   CROM(.sdata) : > .
    .CROM.data 	                       CROM(.data) : > .

//
// RAM SECTIONS
//
    .sdabase 					    : > ram_memory	
    .sbss 					        : > .
    .sdata 					        : > .
    .data 					        : > .
    .bss 					        : > .

    .ghcovfz					  CLEAR : > .
    .ghcovcz					  CLEAR : > .
    .ghcovdz					  CLEAR : > .
    .heap                   ALIGN(16) PAD( heap_reserve +
	    // Add space for call-graph profiling if used:
	    (isdefined(__ghs_indgcount)?(2000+(sizeof(.text)/2)):0) +
	    // Add estimated space for call-count profiling if used:
	    (isdefined(__ghs_indmcount)?10000:0) )
	    						: > .
    .stack                 ALIGN(16) PAD(stack_reserve) : > ram_rsvd2


__bss_start__ = ADDR(.bss);
__bss_end__ = ENDADDR(.bss);
__heap_end__ = ENDADDR(.bss);
__data_load_start__ = ADDR(.CROM.data);
__data_start__ = ADDR(.data);
__data_end__ = ENDADDR(.data);
__text_start__ = 0;
__text_load_start__ = 0;
__text_end__ = 0;


//
// These special symbols mark the bounds of RAM and ROM memory.
// They are used by the MULTI debugger.
//
    __ghs_romstart  = MEMADDR(flash_vector);
    __ghs_romend    = MEMENDADDR(flash_rsvd2);
    __ghs_ramstart  = MEMADDR(ram_rsvd1);
    __ghs_ramend    = MEMENDADDR(ram_rsvd2);

//
// These special symbols mark the bounds of RAM and ROM images of boot code.
// They are used by the GHS startup code (_start and __ghs_ind_crt0).
//
    __ghs_rombootcodestart  = ADDR(.text);
    __ghs_rombootcodeend    = ENDADDR(.fixtype);
    __ghs_rambootcodestart  = 0;
    __ghs_rambootcodeend    = 0;
}


