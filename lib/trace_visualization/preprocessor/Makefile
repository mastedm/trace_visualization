LEX = flex
CC  = gcc
CPP = g++

LDFLAGS =-lfl

CPPUNIT_BIN_CFG = cppunit-config
CPPUNIT_CFLAGS  = `$(CPPUNIT_BIN_CFG) --cflags`
CPPUNIT_LIBS    = `$(CPPUNIT_BIN_CFG) --libs`

CFLAGS   =-O0 -Wall -g
CPPFLAGS =-O0 -Wall $(CPPUNIT_CFLAGS) -g
# CPPFLAGS =-O0 -Wall -std=c++11 $(CPPUNIT_CFLAGS)

.cpp.o :
	$(CPP) $(CPPFLAGS) -o $@ -c $< 

.c.o :
	$(CC) $(CFLAGS) -o $@ -c $< 

%.cppo : %.c
	$(CPP) $(CPPFLAGS) -o $@ -c $< 

preprocessor: preprocessor.o parser_functions.o
	$(CC) -o $@ $(LDFLAGS) $^

preprocessor.c: preprocessor.l
	$(LEX) -o $@ $^

unit_tests: test_main.o hashmap.cppo hashmap_test.o \
            parser_functions.cppo parser_test.o \
            lexeme_table.cppo
	$(CPP) -o $@ $(CPPUNIT_LIBS) $^
	
unit_tests_run: unit_tests
	./unit_tests	

install: preprocessor
	cp preprocessor ../../../bin/
	make clean

clean: 
	rm -f *.o *.cppo preprocessor.c unit_tests preprocessor