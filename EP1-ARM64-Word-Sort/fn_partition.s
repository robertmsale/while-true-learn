.global fn_partition
.align 4

.extern fn_str_should_swap
.extern fn_swap

.include "globals.s"
.include "fn_stack.s"

multiplier .req X5
temp .req X10
low .req X11
high .req X12
pivot .req X13
i .req X14
j .req X15

/**
    int _partition(long X1, long X2)
        X1 = low -> left buffer
        X2 = high -> right buffer
        X0 = Returns partition idx
*/
fn_partition:
    fn_stack_backup_lite
    mov multiplier, #256
    mov low, X1
    mov high, X2
    mov X1, high
    madd pivot, high, multiplier, wordBufPtrGlobal
    mov j, low
    sub i, low, #1
loop:
    cmp j, high
    b.ge end
    madd X1, j, multiplier, wordBufPtrGlobal
    mov X2, pivot
    stp X1, X2, [SP, #-16]!
    bl fn_str_should_swap
    ldp X1, X2, [SP], #16
    cbz X0, skip
    add i, i, #1
    madd X1, i, multiplier, wordBufPtrGlobal
    madd X2, j, multiplier, wordBufPtrGlobal
    bl fn_swap
skip:
    add j, j, #1
    b loop
end:
    add i, i, #1
    madd X1, i, multiplier, wordBufPtrGlobal
    madd X2, high, multiplier, wordBufPtrGlobal
    bl fn_swap
    mov X0, i
    fn_stack_restore
    ret


