compile: 
	bison -d -y compiler.y
	flex compiler.l
	gcc -c lex.yy.c -o compiler.lex.o
	gcc -c y.tab.c -o compiler.y.o
	gcc -o compiler compiler.y.o compiler.lex.o

clean: 
	rm -f compiler *.o