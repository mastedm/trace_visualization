#include <cppunit/extensions/HelperMacros.h>
#include <iostream>
#include "hashmap.h"

using namespace std;

class hashmap_test : public CPPUNIT_NS::TestFixture {
	CPPUNIT_TEST_SUITE(hashmap_test);
	CPPUNIT_TEST(smoke_test);
	CPPUNIT_TEST(complex_test);	
	CPPUNIT_TEST(hashmap_values_test);	
	CPPUNIT_TEST_SUITE_END();
public:
	void smoke_test(void);
	void complex_test(void);
	void hashmap_values_test(void);
};

CPPUNIT_TEST_SUITE_REGISTRATION(hashmap_test);

void hashmap_test::smoke_test() {
	hashmap_t* map = hashmap_new();
	
	const char* value = "value";
	hashmap_put(map, 12345, (char*)value);
	
	void* ptr = hashmap_get(map, 1);
	CPPUNIT_ASSERT(ptr == NULL);
	
	ptr = hashmap_get(map, 12345);
	CPPUNIT_ASSERT(ptr != NULL);
	CPPUNIT_ASSERT(strcmp((char*)ptr, value) == 0);

	hashmap_free(map);
}

void hashmap_test::complex_test() {
	hashmap_t* map = hashmap_new();
	
	CPPUNIT_ASSERT(map != NULL);
	
	for (long i = 0; i < HASHMAP_SIZE << 3; i += HASHMAP_SIZE >> 2) {
		hashmap_put(map, i, (void*)i);
	}

	for (int i = 0; i < HASHMAP_SIZE; i++) {
		if (i % (HASHMAP_SIZE >> 2) == 0) {
			CPPUNIT_ASSERT(map->table[i] != NULL);
		} else {
			CPPUNIT_ASSERT(map->table[i] == NULL);
		}
	}

	for (long i = 0; i < HASHMAP_SIZE << 3; i += HASHMAP_SIZE >> 2) {
		void* ptr = hashmap_get(map, i);
		CPPUNIT_ASSERT(ptr == (void*)i);
		
		CPPUNIT_ASSERT(hashmap_get(map, i + 1) == NULL);
		CPPUNIT_ASSERT(hashmap_get(map, i - 1) == NULL);		
	}
	
	hashmap_free(map);
}

void hashmap_test::hashmap_values_test() {
	hashmap_t* map = hashmap_new();
	
	CPPUNIT_ASSERT(map != NULL);
	
	int k = 2;
	
	for (long i = 0; i < HASHMAP_SIZE * k; i += 1) {
		hashmap_put(map, i, (void*)i);
	}
	
	CPPUNIT_ASSERT(map->size == HASHMAP_SIZE * k);
	
	void** values = hashmap_values(map);
	CPPUNIT_ASSERT(values != NULL);
	
	for (int i = 0; i < map->size; i++) {
		void* value = values[i];
		
		int int_value = (i % k) * HASHMAP_SIZE + i / k;
		CPPUNIT_ASSERT(value == (void*)int_value);
	}

	hashmap_values_free(values);
	hashmap_free(map);	
}