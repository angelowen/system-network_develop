all:
	java -cp antlr-3.5.2-complete.jar org.antlr.Tool myCompiler.g
	javac -cp antlr-3.5.2-complete.jar:. myCompiler_test.java
	java -cp antlr-3.5.2-complete.jar:. myCompiler_test test1.c > test1.j
	java -cp antlr-3.5.2-complete.jar:. myCompiler_test test2.c > test2.j
	java -cp antlr-3.5.2-complete.jar:. myCompiler_test test3.c > test3.j
clean:
	rm *.class 
	rm  myCompilerParser.java myCompilerLexer.java myCompiler.tokens
