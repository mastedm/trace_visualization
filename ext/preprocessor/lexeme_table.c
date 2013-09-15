#include "lexeme_table.h"
#include <stdlib.h>

hashmap_t* lexeme_table_new() {
	return hashmap_new();
}

lexeme_t* install_lexeme(hashmap_t* lexeme_table, const char* name, const char* source, long numeric) {
	lexeme_t* lexeme = NULL;

	void* ptr = hashmap_get(lexeme_table, numeric);

	if (ptr == NULL) {
		lexeme = (lexeme_t*)malloc(sizeof(lexeme_t));
		
		lexeme->name = name;
		lexeme->source = source;
		lexeme->numeric = numeric;
		
		hashmap_put(lexeme_table, numeric, lexeme);
	} else {
		lexeme = (lexeme_t*)ptr;
	}

	return lexeme;
}

int compare_lexeme(const void* a, const void* b) {
	return ((lexeme_t*)*(void**)a)->numeric - ((lexeme_t*)*(void**)b)->numeric;
}

void reorder_lexemes(hashmap_t* lexeme_table) {
	void** values = hashmap_values(lexeme_table);
	
	qsort(values, lexeme_table->size, sizeof(void*), compare_lexeme);
	
	int  ord  = 0;
	long prev = -1;

	for (int i = 0; i < lexeme_table->size; i++) {
		int numeric = ((lexeme_t*)values[i])->numeric;
		
		if (numeric != prev) {
			ord += 1;
			prev = numeric;
		}
		
		((lexeme_t*)values[i])->ord = ord;
	}
}