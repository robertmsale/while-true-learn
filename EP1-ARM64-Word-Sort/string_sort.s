.global main
.global BP
.align 4

.macro __prep_syscall, imm1
    movz X16, #0x200, lsl #16
    add X16, X16, \imm1
.endm

.macro __get_var, reg, name
    adrp \reg, \name@PAGE
    add \reg, \reg, \name@PAGEOFF
.endm

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
    __get_var X1, buf_stdin         // Load STDIn buffer space ptr
    movz X2, #0x20, lsl #16         // 0x200000
    __prep_syscall #3               // READ Syscall
    svc 0x80                        // Call to kernel software interruptor
    ret

/**
    long _get_str_address(long X1, char* X2)
        X1 = Index of string in buffer
        X2 = Words Buffer Pointer
        X0 = Returns address
*/
_get_str_address:
    mov X2, #256
    __get_var X0, buf_words
    madd X0, X1, X2, X0
    ret

/**
    void _stdin_to_buf()
        X1 = STDIn Buffer Pointer
        X2 = Words Buffer Pointer
        X3 = Character Comparator
        X4 = Word Size
        W5 = Current Character
        X19 = Word Count
*/
_stdin_to_buf:
    stp X29, X30, [SP, #-16]!       // Stack management
    mov X19, #0                     // Initialize word count
    mov X4, #0                      // Set word size to zero
    __get_var X1, buf_stdin         // Get stdin buffer ptr
    __get_var X2, buf_words         // Get word buffer
    sub X1, X1, 1                   // i--
_stdin_to_buf_loop:
    add X1, X1, 1                   // i++
    ldrb W5, [X1]                   // load current char from stdin buf
    cbz X5, _stdin_to_buf_end       // if null terminator, we're done
    mov X3, #'\n'                   // if '\n' terminator, we're done
    cmp X3, X5                      // ^^^^^
    b.eq _stdin_to_buf_end          // ^^^^^
    mov X3, #' '                    // if ' ', we are not in the word boundary
    cmp X3, X5                      // ^^^^^
    b.eq _stdin_to_buf_invalid      // ^^^^^ Skip adding to buffer
    strb W5, [X2], #1               // Store in buffer
    add X4, X4, 1                   // Increment word size
    b _stdin_to_buf_loop            // Continue
_stdin_to_buf_invalid:
    cbz X4, _stdin_to_buf_loop      // If "  " or something, continue
    strb WZR, [X2, #1]              // Null terminate word in buffer
    add X19, X19, #1                // (Word Count)++
    stp X1, XZR, [SP, #-16]!        // Backup STDIn buf ptr
    mov X1, X19                     // Copy word count into param 1
    bl _get_str_address             // Get String Address
    mov X2, X0                      // Put new buf address where it belongs
    ldp X1, X4, [SP], #16           // Restore STDIn buf ptr
    mov X4, #0
    b _stdin_to_buf_loop            // Continue
_stdin_to_buf_end:
    ldp X29, X30, [SP], #16         // Stack management
    ret

/**
    void _swap(char* X1, char* X2)
        X1 = left string
        X2 = right string
        X5 = i
        Q0 = left 16 bytes
        Q1 = right 16 bytes
*/
_swap:
    mov X5, #16                     // i = 16
_swap_loop:
    ldr Q0, [X1], #16               // Load left string, X1 += 16
    ldr Q1, [X2], #16               // Load right string, X2 += 16
    str Q0, [X2, #-16]              // Store left in right
    str Q1, [X1, #-16]              // Store right in left
    sub X5, X5, #1                  // i--
    cbnz X5, _swap_loop             // i > 0 then continue
    ret

/**
    long _str_should_swap(char* X1, char* X2)
        X1 = left string
        X2 = right string
        W3 = curr left char
        W4 = curr right char
        X0 = return
            -> 0 = no
            -> _ = yes
*/
_str_should_swap:
    mov X0, #0                      // assume no
_str_should_swap_loop:
    ldrb W3, [X1], #1               // W3 = *(X1++)
    ldrb W4, [X2], #1               // W4 = *(X2++)
    cmp W3, W4                      
    b.lt _str_should_swap_yes       // W3 < W4 then yes
    b.gt _str_should_swap_end       // W3 > W4 we're done
    cbz W3, _str_should_swap_end    // Damn, this was the bug the whole time D:
    b _str_should_swap_loop
_str_should_swap_yes:
    mov X0, #1
    ret
_str_should_swap_end:
    ret

/**
    int _partition(long X1, long X2)
        X1 = low -> left buffer
        X2 = high -> right buffer
        X10 = temp
        X11 = low
        X12 = high
        X13 = char* pivot
        X14 = i
        X15 = j
        X0 = Returns partition idx
*/
_partition:
    stp X29, X30, [SP, #-16]!       // Stack management
    stp X1, X2, [SP, #-16]!         // Backup low & high
    mov X11, X1
    mov X12, X2
    mov X1, X2                      // Move high into param 1
    bl _get_str_address             // Get char* pivot
    mov X13, X0                     // Put pivot into proper register
    mov X15, X11                    // Load low in into j
    sub X14, X15, 1                 // i = low - 1
_partition_loop:
    cmp X15, X12                    // if j >= high we're done
    b.ge _partition_end
    mov X1, X15                     // Get string at index j
    bl _get_str_address             // ^^
    mov X1, X0                      // moving string at idx j to param 1
    mov X2, X13                     // move char* pivot into param 2
    stp X1, X2, [SP, #-16]!         // Backup strings
    bl _str_should_swap
    ldp X1, X2, [SP], #16           // Restore strings
    cbz X0, _partition_loop_skip    // if no need to swap, skip!
    add X14, X14, #1                // i++
    mov X1, X14                     // param 1 = i
    bl _get_str_address             
    mov X10, X0                     // X10 = buf[i]
    mov X1, X15                     // param 1 = j
    bl _get_str_address
    mov X1, X10                     // param 1 = buf[i]
    mov X2, X0                      // param 2 = buf[j]
    bl _swap
_partition_loop_skip:
    add X15, X15, #1                // j++
    b _partition_loop               // Continue
_partition_end:
    add X14, X14, #1                // i++
    mov X1, X14                     // param 1 = i
    bl _get_str_address
    mov X10, X0                     // X10 = buf[i]
    mov X1, X12                     // param 1 = high
    bl _get_str_address
    mov X1, X0                      // param 1 = buf[high]
    mov X2, X10                     // param 2 = buf[i]
    bl _swap
    mov X0, X14                     // return i
    ldp X1, X2, [SP], #16           // Stack management
    ldp X29, X30, [SP], #16         // Stack management
    ret

/**
    void _sort_recursive(long X1, long X2)
        X1 = low
        X2 = high
        STACK = 32 Bytes [
            low, 
            high,
            partition,
            return instruction
        ]
*/
_sort_recursive:
    cmp X1, X2
    b.ge _sort_recursive_end_early
    sub SP, SP, #32
    stp X1, X2, [SP]
    str X30, [SP, #24]

    bl _partition
    str X0, [SP, #16]               // put partition in stack
    sub X2, X0, #1                  // X2 = partition - 1
    ldr X1, [SP]                    // X1 = low
    bl _sort_recursive

    ldr X1, [SP, #16]               // X1 = partition + 1
    add X1, X1, #1                  // ^^^^^^
    ldr X2, [SP, #8]                // X2 = high
    bl _sort_recursive

    ldr X30, [SP, #24]
    ldr X0, [SP, #16]
    ldp X1, X2, [SP]
    add SP, SP, #32
_sort_recursive_end_early:
    ret

_print_whole_buffer:
    stp X29, X30, [SP, #-16]!
    mov X3, #-1

_print_whole_buffer_loop:
    add X3, X3, 1
    cmp X3, X19
    b.gt _print_whole_buffer_end
    mov X1, X3
    bl _get_str_address
    mov X1, X0
    bl _print_256
    __get_var X1, buf_space 
    mov X2, #1
    bl _print
    b _print_whole_buffer_loop
_print_whole_buffer_end:
    __get_var X1, buf_nl 
    mov X2, #1
    bl _print
    ldp X29, X30, [SP], #16
    ret

main:
    stp X19, XZR, [SP, #-16]!
    bl _get_stdin
    bl _stdin_to_buf

    mov X1, #0
    mov X2, X19
BP:
    bl _sort_recursive
    bl _print_whole_buffer

    mov X0, #0
    __prep_syscall #1
    ldp X19, X0, [SP], #16         // Pop stack
    svc 0x80

.align 8
.data
buf_hello_world: .asciz "Hello, World!\n\0"
buf_nl: .asciz "\n"
buf_space: .asciz " \0"
buf_stdin: .space 2097152
buf_words: .space 2097152 // 256 bytes apart

/*
        [ ]
         ^ 256 bytes

        [ ] [ ] [ ] [ ] [ ]
*/