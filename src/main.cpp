#include <iostream>
#include "core/redis_value.h"

int main() {
    std::cout << "Mini-Redis Server" << std::endl;
    
    // Simple test of RedisValue
    std::string test_value = "Hello, Redis!";
    RedisValue value(test_value);
    std::cout << "Test value: " << value.value() << std::endl;
    
    return 0;
}