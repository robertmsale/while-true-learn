OBJDIR = build
OBJS = $(OBJDIR)/string_sort.o
EXEC = string_sort.exe


# Rule to link all object files into the final executable
$(EXEC): $(OBJDIR) $(OBJS)
	ld -o $(EXEC) $(OBJS) -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _main -arch arm64

# Rule to assemble each .s file into a .o file
$(OBJDIR)/%.o: %.s | $(OBJDIR)
	as -arch arm64 -o $@ $<

# Clean rule to remove object files and executable
clean:
	rm -f $(OBJS) $(EXEC)
	rmdir $(OBJDIR) || true