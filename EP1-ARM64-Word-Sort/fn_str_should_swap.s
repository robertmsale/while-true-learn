.global fn_str_should_swap
.align 4

/**
    long fn_str_should_swap(char* X1, char* X2)
        X1 = left string
        X2 = right string
        W3 = curr left char
        W4 = curr right char
        X0 = return
            -> 0 = no
            -> _ = yes
*/
fn_str_should_swap:
    mov X0, #0                      // assume no
loop:
    ldrb W3, [X1], #1               // W3 = *(X1++)
    ldrb W4, [X2], #1               // W4 = *(X2++)
    cmp W3, W4                      
    b.lt yes       // W3 < W4 then yes
    b.gt end       // W3 > W4 we're done
    cbz W3, end    // Left shorter than right
    b loop
yes:
    mov X0, #1
    ret
end:
    ret