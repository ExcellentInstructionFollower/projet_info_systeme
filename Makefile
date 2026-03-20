calc: 
# 	bison -d -y compiler.y
	flex compiler.l
	gcc lex.yy.c -o compiler
# 	gcc -c y.tab.c -o compiler.y.o
# 	gcc -o compiler compiler.y.o compiler.lex.o

clean: 
	rm -f compiler *.o