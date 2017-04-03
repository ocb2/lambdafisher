#all:

.PHONY : test

test: #test/lex.py src/cl/lambda.cl
	python3 test/lex.py