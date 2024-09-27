.global fn_stdin_to_buf
.align 4

.include "fn_stack.s"
.include "globals.s"

stdinBufPtr .req X1
wordsBufPtr .req X2
charCmp .req W3
wordSize .req X4
currChar .req W5

/**
    void fn_stdin_to_buf(char* stdinBufPtr, char* wordsBufPtr)
*/
fn_stdin_to_buf:
    fn_stack_backup_lite
    mov wordCount, #0
    mov wordSize, #0