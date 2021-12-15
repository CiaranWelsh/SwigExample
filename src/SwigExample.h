//
// Created by Ciaran on 15/12/2021.
//

#ifndef SWIGEXAMPLE_SWIGEXAMPLE_H
#define SWIGEXAMPLE_SWIGEXAMPLE_H

#include <vector>
#include <string>
#include <unordered_map>
#include <stdexcept>
#include <memory>

class Foo {
public:
    Foo(int x_)
        : x(x_){}
    int x;
};


class SpecialFooMap{
public:
    SpecialFooMap() = default;

    SpecialFooMap(const std::vector<std::string>& labels, const std::vector<int>& values){
        insertFoos(labels, values);
    }

    void insertFoos(const std::vector<std::string>& labels, const std::vector<int>& values){
        if (labels.size() != values.size())
            throw std::invalid_argument("labels and values are not the same size");
        for (int i=0; i<labels.size(); i++){
            map_[labels[i]] = std::make_unique<Foo>(values[i]);
        }
    }
    std::unordered_map<std::string, std::unique_ptr<Foo>> map_;
};

#endif //SWIGEXAMPLE_SWIGEXAMPLE_H
