OBJDIR = build
OBJS = $(OBJDIR)/string_sort.o $(OBJDIR)/fn_stack.o $(OBJDIR)/fn_stdin_to_buf.o $(OBJDIR)/fn_word_len.o $(OBJDIR)/fn_swap.o
EXEC = string_sort.exe

C_SRC = cstring_sort.c
C_OBJ = $(OBJDIR)/cstring_sort.o
C_EXEC = cstring_sort.exe

# Rule to link all object files into the final executable
$(EXEC): $(OBJDIR) $(OBJS)
	ld -o $(EXEC) $(OBJS) -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e main -arch arm64

# Rule to compile C source file into separate executable
$(C_EXEC): $(C_OBJ)
	clang -g -o $(C_EXEC) $(C_OBJ)

# Rule to compile the C source into an object file
$(C_OBJ): $(C_SRC) | $(OBJDIR)
	clang -g -c -o $(C_OBJ) $(C_SRC)

# Rule to assemble each .s file into a .o file
$(OBJDIR)/%.o: %.s | $(OBJDIR)
	as -arch arm64 -o $@ $<

# Clean rule to remove object files and executable
clean:
	rm -f $(OBJS) $(EXEC)
	rmdir $(OBJDIR) || true