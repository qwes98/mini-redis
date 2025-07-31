#include <gtest/gtest.h>
#include "core/redis_value.h"
#include <string>

// Basic test fixture for RedisValue
class RedisValueBasicTest : public ::testing::Test {
protected:
    void SetUp() override {
        test_string = "hello";
        empty_string = "";
        number_string = "123";
    }
    
    std::string test_string;
    std::string empty_string;
    std::string number_string;
};

// Test basic construction
TEST_F(RedisValueBasicTest, BasicConstruction) {
    RedisValue value(test_string);
    EXPECT_EQ(value.value(), "hello");
}

// Test with empty string
TEST_F(RedisValueBasicTest, EmptyString) {
    RedisValue value(empty_string);
    EXPECT_EQ(value.value(), "");
    EXPECT_TRUE(value.value().empty());
}

// Test with numeric string
TEST_F(RedisValueBasicTest, NumericString) {
    RedisValue value(number_string);
    EXPECT_EQ(value.value(), "123");
    EXPECT_EQ(value.value().length(), 3);
}

// Test copy semantics
TEST_F(RedisValueBasicTest, CopySemantics) {
    std::string original = "original";
    RedisValue value(original);
    
    // Should be a copy, not reference
    EXPECT_NE(&value.value(), &original);
    
    // Modify original - RedisValue should not change
    original = "modified";
    EXPECT_EQ(value.value(), "original");
    EXPECT_EQ(original, "modified");
}

// Test reference stability
TEST_F(RedisValueBasicTest, ReferenceStability) {
    RedisValue value(test_string);
    
    const std::string& ref1 = value.value();
    const std::string& ref2 = value.value();
    
    // Should return reference to same object
    EXPECT_EQ(&ref1, &ref2);
}

// Test with binary data
TEST_F(RedisValueBasicTest, BinaryData) {
    std::string binary = std::string("\x00\x01\xFF", 3);
    RedisValue value(binary);
    
    EXPECT_EQ(value.value(), binary);
    EXPECT_EQ(value.value().length(), 3);
    EXPECT_EQ(static_cast<unsigned char>(value.value()[0]), 0x00);
    EXPECT_EQ(static_cast<unsigned char>(value.value()[2]), 0xFF);
}