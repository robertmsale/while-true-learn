.global main
.global BP
.align 4

.extern fn_stdin_to_buf
.extern fn_sort_recursive

.macro __prep_syscall, imm1
    movz X16, #0x200, lsl #16
    add X16, X16, \imm1
.endm

.macro __get_var, reg, name
    adrp \reg, \name@PAGE
    add \reg, \reg, \name@PAGEOFF
.endm

.include "fn_stack.s"
.include "globals.s"

/**
    size_t _print(char* X1)
        X0 = STDOut FD
        X1 = string to print
        X2 = size of the buffer
        X16 = syscall
*/
_print_256:
    mov X2, #256                    // Buffer size 256
_print:
    mov X0, #1                      // STDOut File Descriptor
    __prep_syscall #4               // X16 syscall #4 (write)
    svc #0x80                       // Call to kernel software interruptor
    ret

/**
    void _get_stdin()
        X0 = STDIn FD
*/
_get_stdin:
    mov X0, #0                      // STDIn File Descriptor
    mov X1, stdinBufPtrGlobal
    movz X2, #0x20, lsl #16         // 0x200000 max read size
    __prep_syscall #3               // READ Syscall
    svc 0x80                        // Call to kernel software interruptor
    ret

_print_whole_buffer:
    fn_stack_backup_lite
    mov X3, #-1
    mov X5, #256
_print_whole_buffer_loop:
    add X3, X3, 1
    cmp X3, X19
    b.gt _print_whole_buffer_end
    madd X0, X3, X5, wordBufPtrGlobal
    bl _print_256
    __get_var X1, buf_space 
    mov X2, #1
    bl _print
    b _print_whole_buffer_loop
_print_whole_buffer_end:
    __get_var X1, buf_nl 
    mov X2, #1
    bl _print
    fn_stack_restore
    ret

main:
    stp wordCount, stdinBufPtrGlobal, [SP, #-16]!
    stp wordBufPtrGlobal, twoMegabytes, [SP, #-16]!
    movz twoMegabytes, #0x20, lsl #16
    sub SP, SP, twoMegabytes
    mov stdinBufPtrGlobal, SP
    sub SP, SP, twoMegabytes
    mov wordBufPtrGlobal, SP
    bl _get_stdin
    bl fn_stdin_to_buf

    mov X1, #0
    mov X2, wordCount
BP:

    bl _print_whole_buffer
    bl fn_sort_recursive
    bl _print_whole_buffer

    mov X0, #0
    __prep_syscall #1
    add SP, SP, twoMegabytes
    add SP, SP, twoMegabytes
    ldp wordBufPtrGlobal, twoMegabytes, [SP], #16         // Pop stack
    ldp wordCount, stdinBufPtrGlobal, [SP], #16         // Pop stack
    svc 0x80

.align 8
.data
buf_nl: .asciz "\n"
buf_space: .asciz " "

/*
        [ ]
         ^ 256 bytes

        [ ] [ ] [ ] [ ] [ ]
*/