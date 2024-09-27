.global fn_sort_recursive
.align 4

.extern fn_partition

low .req X1
high .req X2

/**
    void _sort_recursive(long low, long high)
        STACK = 32 Bytes [
            low, 
            high,
            partition,
            return instruction
        ]
*/
fn_sort_recursive:
    cmp low, high
    b.ge end
    sub SP, SP, #32
    stp low, high, [SP]
    str X30, [SP, #24]

    bl fn_partition
    str X0, [SP, #16]
    sub high, X0, #1
    ldr low, [SP]
    bl fn_sort_recursive

    ldr low, [SP, #16]
    add low, low, #1
    ldr high, [SP, #8]
    bl fn_sort_recursive
    ldr X30, [SP, #24]
    add SP, SP, #32
end:
    ret