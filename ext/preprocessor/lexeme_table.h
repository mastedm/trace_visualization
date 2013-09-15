#ifndef __LEXEME_TABLE_H__
#define __LEXEME_TABLE_H__

#include "lexeme.h"
#include "hashmap.h"

extern hashmap_t* lexeme_table_new();

extern lexeme_t* install_lexeme(hashmap_t* lexeme_table, const char* name, const char* source, long numeric);

extern void reorder_lexemes(hashmap_t* lexeme_table);

#endif