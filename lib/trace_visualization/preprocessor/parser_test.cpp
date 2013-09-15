#include <cppunit/extensions/HelperMacros.h>
#include <iostream>
#include "lexeme.h"
#include "lexeme_table.h"

const char* yytext;

void output_lexeme(const char* name, long value);

extern void parse_identifier();
extern void parse_ip();
extern void parse_date();

using namespace std;

class parser_test : public CPPUNIT_NS::TestFixture {
	CPPUNIT_TEST_SUITE(parser_test);
	CPPUNIT_TEST(identifier_parser_test);
	CPPUNIT_TEST(lexeme_table_test);	
	CPPUNIT_TEST_SUITE_END();
public:
	void identifier_parser_test(void);
	void lexeme_table_test(void);
};

CPPUNIT_TEST_SUITE_REGISTRATION(parser_test);

lexeme_t lexeme;
// lexeme.name = "";
// lexeme.source = "";
// lexeme.numeric = -1;
// lexeme.ord = -1;

void output_lexeme(const char* name, long value) {
	lexeme.name    = name;
	lexeme.numeric = value;
}

//-----------------------------------------------------------------------------
void parser_test::identifier_parser_test(void) {
	yytext = "[123]";
	
	parse_identifier();
	
	CPPUNIT_ASSERT(strcmp("ID", lexeme.name) == 0);
}


//-----------------------------------------------------------------------------
void parser_test::lexeme_table_test(void) {
	hashmap_t* table = lexeme_table_new();
	
	lexeme_t* lexeme         = install_lexeme(table, "id", "[123]", 123);
	lexeme_t* another_lexeme = install_lexeme(table, "id", "[124]", 124);
	lexeme_t* repeat_lexeme  = install_lexeme(table, "id", "[123]", 123);

	CPPUNIT_ASSERT(lexeme         != NULL);	
	CPPUNIT_ASSERT(another_lexeme != NULL);	
	CPPUNIT_ASSERT(repeat_lexeme  != NULL);	
	
	CPPUNIT_ASSERT_EQUAL(lexeme, repeat_lexeme);	

	reorder_lexemes(table);

	CPPUNIT_ASSERT_EQUAL(1, lexeme->ord);
	CPPUNIT_ASSERT_EQUAL(2, another_lexeme->ord);
}




