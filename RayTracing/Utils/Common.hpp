//
//  Common.hpp
//  RayTracing
//
//  Created by Willy Tai on 5/26/23.
//

#ifndef Common_hpp
#define Common_hpp

#include <memory>

template <typename T>
using Unique = std::unique_ptr<T>;

template <typename T, typename ... Args>
constexpr Unique<T> CreateUnique(Args&& ... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}

template <typename T>
using Ref = std::shared_ptr<T>;

template <typename T, typename ... Args>
constexpr Ref<T> CreateRef(Args&& ... args) {
    return std::make_shared<T>(std::forward<Args>(args)...);
}


#endif /* Common_hpp */
