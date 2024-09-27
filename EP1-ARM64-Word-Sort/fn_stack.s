.align 4


/**
    Backup frame pointer & link register to the stack & allocate that space
*/
.macro fn_stack_backup_lite
    stp fp, lr, [SP, #-16]!         // Backup Frame Pointer & Link Register
.endm


/**
    Same as above, but also sets up current frame
*/
.macro fn_stack_backup
    fn_stack_backup_lite
    mov fp, sp                      // Set Frame Pointer to current stack location
.endm

/**
    Restore frame pointer & link register from stack. Deallocate.
*/
.macro fn_stack_restore
    ldp fp, lr, [SP], #16           // Restore frame pointer & link register
.endm

/**

*/