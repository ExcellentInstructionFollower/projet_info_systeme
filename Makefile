compile: 
	bison -b target/y -d -y src/compiler/compiler.y
	flex -o target/lex.yy.c src/compiler/compiler.l
	gcc -c target/lex.yy.c -o target/compiler.lex.o
	gcc -c target/y.tab.c -o target/compiler.y.o
	gcc -o target/compiler target/compiler.y.o target/compiler.lex.o

interprete: 
	bison -b target/y -d -y src/interpreter/interpreter.y
	flex -o target/lex.yy.c src/interpreter/interpreter.l
	gcc -c target/lex.yy.c -o target/interpreter.lex.o
	gcc -c target/y.tab.c -o target/interpreter.y.o
	gcc -o target/interpreter target/interpreter.y.o target/interpreter.lex.o

clean: 
	rm -f target/* f_* 