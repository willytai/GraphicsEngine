//
//  CompareUtils.hpp
//  RayTracing
//
//  Created by Willy Tai on 6/10/23.
//

#ifndef CompareUtils_hpp
#define CompareUtils_hpp

#define EPSILON 1e-6

namespace test {

static bool fequal(float x, float y) {
    return std::fabs(x-y) < EPSILON;
}

}

#endif /* CompareUtils_hpp */
