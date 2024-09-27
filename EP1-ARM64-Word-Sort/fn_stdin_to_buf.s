.global fn_stdin_to_buf
.align 4

.include "fn_stack.s"
.include "globals.s"

stdinBufPtr .req X1
wordsBufPtr .req X2
charCmp .req W3
wordSize .req X4
currChar .req W5
currCharWide .req X5
multiplier .req X6

/**
    void fn_stdin_to_buf()
*/
fn_stdin_to_buf:
    mov wordCount, #0
    mov wordSize, #0
    mov multiplier, #256
    mov stdinBufPtr, stdinBufPtrGlobal
    mov wordsBufPtr, wordBufPtrGlobal
    sub stdinBufPtr, stdinBufPtr, #1        // i--
loop:
    add stdinBufPtr, stdinBufPtr, #1        // i++
    ldrb currChar, [stdinBufPtr]
    cbz currCharWide, end                   // if null, end
    mov charCmp, #'\n'                      // if '\n', end
    cmp currChar, charCmp
    b.eq end
    mov charCmp, #' '                       // if space, word boundary check
    cmp charCmp, currChar
    b.eq invalid
    strb currChar, [wordsBufPtr], #1        // store currChar in words buffer
    add wordSize, wordSize, #1
    b loop
invalid:
    cbz wordSize, loop                                  // handle "    " edge case
    strb WZR, [wordsBufPtr, #1]                          // null terminate string
    add wordCount, wordCount, #1                        // wordCount++
    madd wordsBufPtr, wordCount, multiplier, wordBufPtrGlobal  // calc next word in buffer
    mov wordSize, #0
    b loop
end:
    ret