#include <stdio.h>
#include <time.h>

/**
 * When flex finds a match, yytext points to the first character of the match 
 * in the input buffer. The string itself is part of the input buffer, and is 
 * NOT allocated separately
 */
extern const char* yytext;

/**
 * Implements in two ways: (f)lex and unit-tests
 */
extern void output_lexeme(const char* name, const char* source, int value);

//-----------------------------------------------------------------------------
void parse_identifier() {
	int id;
	sscanf(yytext, "[%d]", &id);
	output_lexeme("ID", yytext, id);
}

//-----------------------------------------------------------------------------
void parse_ip() {
	unsigned ips[4];
	sscanf(yytext, "%d.%d.%d.%d", ips, ips + 1, ips + 2, ips + 3);
	unsigned result = (((ips[0] << 24) & 0xFF000000) | ((ips[1] << 16) & 0xFF0000) | ((ips[2] << 8) & 0xFF00) | (ips[3] & 0xFF));
	output_lexeme("IP", yytext, result);
}

//-----------------------------------------------------------------------------
void parse_date() {
	struct tm tm;
	time_t t;
	
	if (strptime(yytext, "[%d %b %Y %H:%M:%S]", &tm) == NULL) 
		/* handle error */ ;
		
	t = mktime(&tm);
	
	output_lexeme("TIME", yytext, t);
}