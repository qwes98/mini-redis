#pragma once

#include <string>
#include <deque>
#include <unordered_map>
#include <unordered_set>
#include <set>

enum class RedisValueType {
    String,
    List,
    Hash,
    Set,
    SortedSet,
};

class RedisValue {
public:
    using RedisString = std::string;
    using RedisList = std::deque<RedisValue>;
    using RedisHash = std::unordered_map<RedisString, RedisValue>;
    using RedisSet = std::unordered_set<RedisString>;
    using RedisSortedSet = std::set<RedisString>;
    using RedisVariant = std::variant<RedisString, RedisList, RedisHash, RedisSet, RedisSortedSet>;

    explicit RedisValue(RedisString& value) : type_(RedisValueType::String), value_(value) {}
    explicit RedisValue(RedisList& value) : type_(RedisValueType::List), value_(value) {}
    explicit RedisValue(RedisHash& value) : type_(RedisValueType::Hash), value_(value) {}
    explicit RedisValue(RedisSet& value) : type_(RedisValueType::Set), value_(value) {}
    explicit RedisValue(RedisSortedSet& value) : type_(RedisValueType::SortedSet), value_(value) {}

    const RedisVariant& value() const { return value_; }
    RedisValueType type() const { return type_;}

private:
    RedisValueType type_;
    RedisVariant value_;
};