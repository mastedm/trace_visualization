#ifndef __LEXEME_H__
#define __LEXEME_H__

struct lexeme_t {
	const char* name;
	const char* source;
	long        numeric;
	int         ord;
};

#endif