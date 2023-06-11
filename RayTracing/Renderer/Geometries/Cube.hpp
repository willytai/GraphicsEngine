//
//  Cube.hpp
//  RayTracing
//
//  Created by Willy Tai on 6/4/23.
//

#ifndef Cube_hpp
#define Cube_hpp

#include "GeometryObj.hpp"
#include "../../Utils/Common.hpp"

class Cube : public GeometryObj
{
public:
    Cube(float x, float y, float z);
    virtual ~Cube() = default;

    static Ref<Cube> Create(float x, float y, float z);

private:
    float   _x;
    float   _y;
    float   _z;
};

#endif /* Cube_hpp */
