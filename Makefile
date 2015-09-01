LIB_ANTLR := lib/antlr.jar
ANTLR_SCRIPT := Micro.g4

all: group compiler

group:
	@echo "Warren Getlin  Robert Clark"
compiler:
	rm -rf build
	mkdir build
	java -cp $(LIB_ANTLR) org.antlr.v4.Tool -o build $(ANTLR_SCRIPT)
	rm -rf classes
	mkdir classes
	javac -cp $(LIB_ANTLR) -d classes src/*.java build/*.java
clean:
	rm -rf classes build
test:
	@echo "Fibonacci test"
	java -cp src/ Micro fibonacci.micro
	@echo "Loop test"
	java -cp src/ Micro loop.micro
	@echo "Loopbreak test"
	java -cp src/ Micro loopbreak.micro
	@echo "Nested test"
	java -cp src/ Micro nested.micro
	@echo "Sqrt test"
	java -cp src/ Micro sqrt.micro

.PHONY: all group compiler clean
