/* See LICENSE file for copyright and license details. */

ENTRY(_boot)

MEMORY
{
	rom (rx!w) : ORIGIN = 0x20000000, LENGTH = DEFINED(__rom_size) ? __rom_size : 0x7a120
	ram (w!rx) : ORIGIN = 0x80000000, LENGTH = 0x4000
}

PHDRS
{
	text PT_LOAD;
	ram_init PT_LOAD;
	ram PT_LOAD;
	tls_init PT_TLS;
	tls PT_TLS;
}

SECTIONS
{
	PROVIDE(__stack = ORIGIN(ram) + LENGTH(ram));

	.init : {
		KEEP(*(.text.init.enter))
		KEEP(*(.data.init.enter))
		KEEP(*(SORT_BY_NAME(.init) SORT_BY_NAME(.init.*)))
	} >rom AT>rom :text

	.text : {
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.* .opd .opd.*)
		*(.gnu.linkonce.t.*)
		KEEP(*(.fini .fini.*))
		__text_end = .;

		PROVIDE(__etext = __text_end);
		PROVIDE(_etext = __text_end);
		PROVIDE(etext = __text_end);

		. = ALIGN(8);

		PROVIDE_HIDDEN(__preinit_array_start = .);
		KEEP(*(.preinit_array))
		PROVIDE_HIDDEN(__preinit_array_end = .);

		PROVIDE_HIDDEN(__init_array_start = .);
		KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
		KEEP(*(.init_array .ctors))
		PROVIDE_HIDDEN(__init_array_end = .);

		PROVIDE_HIDDEN(__fini_array_start = .);
		KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
		KEEP(*(.fini_array .dtors))
		PROVIDE_HIDDEN(__fini_array_end = .);
	} >rom AT>rom :text

	.rodata : {
		*(.rdata)
		*(.rodata .rodata.*)
		*(.gnu.linkonce.r.*)

		. = ALIGN(8);

		*(.srodata.cst16)
		*(.srodata.cst8)
		*(.srodata.cst4)
		*(.srodata.cst2)
		*(.srodata .srodata.*)
	} >rom AT>rom :text

	.data.rel.ro : {
		*(.data.rel.ro .data.rel.ro.*)
	} >rom AT>rom :text

	.preserve (NOLOAD) : {
		PROVIDE(__preserve_start__ = .);
		KEEP(*(SORT_BY_NAME(.preserve.*)))
		KEEP(*(.preserve))
		PROVIDE(__preserve_end__ = .);
	} >ram AT>ram :ram

	.data : ALIGN_WITH_INPUT {
		*(.data .data.*)
		*(.gnu.linkonce.d.*)

		. = ALIGN(8);

		PROVIDE(__global_pointer$ = . + 0x800);
		PROVIDE(_gp = . + 0x8000);
		*(.sdata .sdata.* .sdata2.*)
		*(.gnu.linkonce.s.*)
	} >ram AT>rom :ram_init
	PROVIDE(__data_start = ADDR(.data));
	PROVIDE(__data_source = LOADADDR(.data));

	.tdata : ALIGN_WITH_INPUT {
		*(.tdata .tdata.* .gnu.linkonce.td.*)
		PROVIDE(__data_end = .);
		PROVIDE(__tdata_end = .);
	} >ram AT>rom :tls_init :ram_init
	PROVIDE(__tls_base = ADDR(.tdata));
	PROVIDE(__tdata_start = ADDR(.tdata));
	PROVIDE(__tdata_source = LOADADDR(.tdata));
	PROVIDE(__tdata_source_end = LOADADDR(.tdata) + SIZEOF(.tdata));
	PROVIDE(__data_source_end = __tdata_source_end);
	PROVIDE(__tdata_size = SIZEOF(.tdata));

	PROVIDE(__edata = __data_end);
	PROVIDE(_edata = __data_end);
	PROVIDE(edata = __data_end);
	PROVIDE(__data_size = __data_end - __data_start);
	PROVIDE(__data_source_size = __data_source_end - __data_source);

	.tbss (NOLOAD) : {
		*(.tbss .tbss.* .gnu.linkonce.tb.*)
		*(.tcommon)
		PROVIDE(__tls_end = .);
		PROVIDE(__tbss_end = .);
	} >ram AT>ram :tls :ram

	PROVIDE(__bss_start = ADDR(.tbss));
	PROVIDE(__tbss_start = ADDR(.tbss));
	PROVIDE(__tbss_offset = ADDR(.tbss) - ADDR(.tdata));
	PROVIDE(__tbss_size = SIZEOF(.tbss));
	PROVIDE(__tls_size = __tls_end - __tls_base);
	PROVIDE(__tls_align = MAX(ALIGNOF(.tdata), ALIGNOF(.tbss)));
	PROVIDE(__tls_size_align = (__tls_size + __tls_align - 1) & ~(__tls_align - 1));

	.tbss_space (NOLOAD) : {
		. = ADDR(.tbss);
		. = . + SIZEOF(.tbss);
	} >ram AT>ram :ram

	.bss (NOLOAD) : {
		*(.sbss*)
		*(.gnu.linkonce.sb.*)
		*(.bss .bss.*)
		*(.gnu.linkonce.b.*)
		*(COMMON)

		. = ALIGN(8);

		__bss_end = .;
	} >ram AT>ram :ram
	PROVIDE(__non_tls_bss_start = ADDR(.bss));
	PROVIDE(__end = __bss_end);
	_end = __bss_end;
	PROVIDE(end = __bss_end);
	PROVIDE(__bss_size = __bss_end - __bss_start);

	PROVIDE(__heap_start = __end);
	PROVIDE(__heap_end = __stack - (DEFINED(__stack_size) ? __stack_size : 0x400));
	PROVIDE(__heap_size = __heap_end - __heap_start);

	.heap (NOLOAD) : {
		. += (DEFINED(__heap_size_min) ? __heap_size_min : 0x1000);
	} >ram :ram

	.stack (NOLOAD) : {
		. += (DEFINED(__stack_size) ? __stack_size : 0x400);
	} >ram :ram

	/DISCARD/ : {
		*(.note .note.*)
		*(.eh_frame .eh_frame.*)
	}

	.stab 0 : { *(.stab) }
	.stabstr 0 : { *(.stabstr) }
	.stab.excl 0 : { *(.stab.excl) }
	.stab.exclstr 0 : { *(.stab.exclstr) }
	.stab.index 0 : { *(.stab.index) }
	.stab.indexstr 0 : { *(.stab.indexstr) }
	.comment 0 : { *(.comment) }
	.gnu.build.attributes : { *(.gnu.build.attributes .gnu.build.attributes.*) }
	.debug 0 : { *(.debug) }
	.line 0 : { *(.line) }
	.debug_srcinfo 0 : { *(.debug_srcinfo) }
	.debug_sfnames 0 : { *(.debug_sfnames) }
	.debug_aranges 0 : { *(.debug_aranges) }
	.debug_pubnames 0 : { *(.debug_pubnames) }
	.debug_info 0 : { *(.debug_info .gnu.linkonce.wi.*) }
	.debug_abbrev 0 : { *(.debug_abbrev) }
	.debug_line 0 : { *(.debug_line .debug_line.* .debug_line_end) }
	.debug_frame 0 : { *(.debug_frame) }
	.debug_str 0 : { *(.debug_str) }
	.debug_loc 0 : { *(.debug_loc) }
	.debug_macinfo 0 : { *(.debug_macinfo) }
	.debug_weaknames 0 : { *(.debug_weaknames) }
	.debug_funcnames 0 : { *(.debug_funcnames) }
	.debug_typenames 0 : { *(.debug_typenames) }
	.debug_varnames 0 : { *(.debug_varnames) }
	.debug_pubtypes 0 : { *(.debug_pubtypes) }
	.debug_ranges 0 : { *(.debug_ranges) }
	.debug_addr 0 : { *(.debug_addr) }
	.debug_line_str 0 : { *(.debug_line_str) }
	.debug_loclists 0 : { *(.debug_loclists) }
	.debug_macro 0 : { *(.debug_macro) }
	.debug_names 0 : { *(.debug_names) }
	.debug_rnglists 0 : { *(.debug_rnglists) }
	.debug_str_offsets 0 : { *(.debug_str_offsets) }
	.debug_sup 0 : { *(.debug_sup) }
	.gnu.attributes 0 : { KEEP (*(.gnu.attributes)) }
}
