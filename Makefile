compile: 
	bison -d -y compiler.y
	flex compiler.l
	gcc -c lex.yy.c -o compiler.lex.o
	gcc -c y.tab.c -o compiler.y.o
	gcc -o compiler compiler.y.o compiler.lex.o

interprete: 
	bison -d -y interpreter.y
	flex interpreter.l
	gcc -c lex.yy.c -o interpreter.lex.o
	gcc -c y.tab.c -o interpreter.y.o
	gcc -o interpreter interpreter.y.o interpreter.lex.o

clean: 
	rm -f compiler interpreter f_* *.o