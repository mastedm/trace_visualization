#ifndef __HASHMAP_H__
#define __HASHMAP_H__

#include <stdlib.h>

#define HASHMAP_SIZE (256)

// typedef struct hashmap_element hashmap_element; 
struct hashmap_element {
	long  key;
	void* value;
	hashmap_element * next;
};

struct hashmap_t {
	hashmap_element** table;
	int size;
};

extern hashmap_t* hashmap_new();
extern int  hashmap_put(hashmap_t* map, long key, void* value);
extern void* hashmap_get(hashmap_t* map, long key);
extern void** hashmap_values(hashmap_t* map); 
extern void hashmap_values_free(void** values);
extern void  hashmap_free(hashmap_t* map);

#endif