.global fn_swap
.align 4

leftString .req X1
rightString .req X2
i .req X5
l16b .req Q0
r16b .req Q1
/**
    void _swap(char* X1, char* X2)
        X1 = left string
        X2 = right string
        X5 = i
        Q0 = left 16 bytes
        Q1 = right 16 bytes
*/
fn_swap:
    mov i, #16                                  // i = 16
loop:
    ldr l16b, [leftString], #16                 // Load left string, X1 += 16
    ldr r16b, [rightString], #16                // Load right string, X2 += 16
    str l16b, [rightString, #-16]               // Store left in right
    str r16b, [leftString, #-16]                // Store right in left
    sub i, i, #1                                // i--
    cbnz i, loop                                // i > 0 then continue
    ret