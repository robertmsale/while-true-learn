.global fn_word_len
.align 4

result .req X0
inputWord .req X1
wordPtr .req X2
currCharFull .req X3
currChar .req W3
cNewLine .req x4
cSpace .req X5

/**
    size_t fn_word_len(char* inputWord)
*/ 
fn_word_len:
    mov cNewLine, #'\n'
    mov cSpace, #' '
    mov wordPtr, inputWord
_loop:
    ldrb currChar, [wordPtr]
    cbz currCharFull, _end
    cmp currCharFull, cNewLine
    b.eq _end
    cmp currCharFull, cSpace
    b.eq _end
    add wordPtr, wordPtr, #1
    b _loop
_end:
    sub result, wordPtr, inputWord
    ret