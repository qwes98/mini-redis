#pragma once

#include <string>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <set>

enum class RedisValueType {
    String,
};

class RedisValue {
public:
    using StringValue = std::string;

    RedisValue(StringValue& value) : type_(RedisValueType::String), value_(value) {}

    const StringValue& value() { return value_; }

private:
    RedisValueType type_;
    StringValue value_;
};