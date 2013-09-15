#include "hashmap.h"
#include <stdio.h>

hashmap_t* hashmap_new() {
	hashmap_t* hashmap = (hashmap_t*)malloc(sizeof(hashmap_t));
	
	hashmap->size = 0;
	hashmap->table = (hashmap_element**)calloc(HASHMAP_SIZE, sizeof(hashmap_element*));

	return hashmap;
}

void* hashmap_get(hashmap_t* map, long key) {
	hashmap_element* ptr;
	int idx = (int)(key % HASHMAP_SIZE);
	
	for (ptr = map->table[idx]; ptr != NULL; ptr = ptr->next) {
		if (ptr->key == key) {
			return ptr->value;
		}
	}
	
	return NULL;	
}

int hashmap_put(hashmap_t* map, long key, void* value) {
	int result = 1;
	
	if (hashmap_get(map, key) == NULL) {
		hashmap_element* ptr;
		hashmap_element* element = (hashmap_element*) malloc(sizeof(hashmap_element));

		element->key   = key;
		element->value = value;
		element->next  = NULL;
		
		int idx = (int)(key % HASHMAP_SIZE);
		ptr = map->table[idx];
	
		if (ptr) {
			while (ptr->next) ptr = ptr->next;
			ptr->next = element;
		} else {
			map->table[idx] = element;
		}

		map->size += 1;

		result = 0;
	} 
	
	return result;	
}

void** hashmap_values(hashmap_t* map) {
	int i = 0;
	int j = 0;
	hashmap_element* ptr;	
	void** values = (void**)malloc(map->size * sizeof(void*));
	
	for (; i < HASHMAP_SIZE; i += 1) {
		ptr = map->table[i];
		
		while (ptr) {
			values[j] = ptr->value;
			ptr = ptr->next;
			j += 1;
		}
	}
	
	return values;
}

void hashmap_values_free(void** values) {
	free(values);
}

void hashmap_free(hashmap_t* map) {
	hashmap_element* ptr;
	hashmap_element* tmp;
	int i;
	for (i = 0; i < HASHMAP_SIZE; i++) {
		for (ptr = map->table[i]; ptr != NULL; ) {
			tmp = ptr;
			ptr = (hashmap_element*)ptr->next;

			free(tmp);
		}
	}
	free(map);
}


