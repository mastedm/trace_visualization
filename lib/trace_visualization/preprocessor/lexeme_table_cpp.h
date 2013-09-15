#ifndef __LEXEME_TABLE_H__
#define __LEXEME_TABLE_H__

#include <map>
#include <vector>
#include <algorithm>
#include "lexeme.h"

class lexeme_table {
public:
	
	~lexeme_table() {
		for (std::map<long, lexeme_t*>::iterator iter = lexeme_table.begin(); iter != lexeme_table.end(); iter++) {
			delete iter->second;
		}
	}
	
	lexeme_t* install_lexeme(const char* name, const char* source, long numeric) {
		std::map<long, lexeme_t*>::iterator iter = lexeme_table.find(numeric);
	
		lexeme_t* lexeme = NULL;
	
		if (iter == lexeme_table.end()) {
			lexeme = new lexeme_t(name, source, numeric);
			lexeme_table[numeric] = lexeme;
		} else {
			lexeme = iter->second;
		}
	
		return lexeme;
	}
	
	void reorder() {
		std::vector<lexeme_t*> tmp; 
		for (std::map<long, lexeme_t*>::iterator iter = lexeme_table.begin(); iter != lexeme_table.end(); iter++) {
			tmp.push_back(iter->second);
		}
		
		std::sort(tmp.begin(), tmp.end(), reorder_function);
		
		int  ord  = 0;
		long prev = -1;
		for (std::vector<lexeme_t*>::iterator iter = tmp.begin(); iter != tmp.end(); iter++) {
			if (prev != (*iter)->numeric) {
				ord += 1;
				prev = (*iter)->numeric;
			}
			
			(*iter)->ord = ord;
		}
	}
	
private:
	std::map<long, lexeme_t*> lexeme_table;
	
	static bool reorder_function(lexeme_t* a, lexeme_t* b) {
		return a->numeric < b->numeric;
	}
};

#endif