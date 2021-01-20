# This is the default target, which will be built when 
# you invoke make
.PHONY: all
all: hello

# This rule tells make how to build hello from hello.cpp
hello: hello.cpp
	g++ -o hello hello.cpp

# This rule tells make to delete hello and hello.o
.PHONY: clean 
clean:
	rm -f hello

# This rule prints pong to console, used as a test for make binary
ping:
	@echo "pong"